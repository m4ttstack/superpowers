# SDD Task Groups Design

## Intent

Long plans take too long under subagent-driven-development (SDD). Every task
costs at least two cold-start agents in strict sequence: one implementer, one
reviewer. A 12-task plan is 24+ agents back to back, each re-reading the same
files and re-running the same tests before doing useful work.

Evidence from 24 SDD ledgers across Matt's repos (239 completed tasks):

- 69% of tasks passed their first review with nothing to fix.
- When a fix loop ran, one round almost always settled it (90 round-1, 14
  round-2, 1 round-3, none past 3).
- About a third of reviews caught something real, including Critical spec
  misses. Reviews earn their place; their count is the cost.

So the time sink is the per-task seat count, not fix loops. This change lets
the controller run consecutive related tasks as one **group**: one
implementer, one review over the group's diff. It also lets the next group's
implementer start while the previous group's review runs, when their files do
not overlap.

## Goals

- Fewer agent seats per plan where tasks are related: a 3-task group costs 2
  seats instead of 6.
- Less wall-clock on long plans, from both grouping and overlap.
- Keep one independent review over every line of code before the final
  review.

## Non-goals

- Changing how writing-plans sizes tasks. Plans stay fine-grained; grouping
  is an execution-time decision.
- Changing the fix loop's caps, the final whole-branch review, or the four
  stop conditions.
- Parallel implementers. At most one implementer is active at a time.
- An upstream PR to obra/superpowers. The fork branch can become one later.

## Anti-goals

The change fails, even if it works, if:

- Groups grow until the review becomes a rubber stamp over a diff too big to
  hold.
- Progress tracking gets coarser: `mattstack:work-progress` and
  `references/resuming.md` read per-task `Task N: complete` lines.
- A judgment-heavy task gets bundled with mechanical ones and reviewed with
  less attention.

## Constraints

- Ships as a fork: `m4ttstack/superpowers`, branch `sdd-task-groups` off tag
  `v7.0.2`, released as tag `v7.0.2-groups.1` (or similar). The local
  marketplace `~/.claude/local-marketplaces/superpowers-pinned` switches its
  `url` and `ref` to the fork's tag.
- Ledger compatibility: every task in a group still gets its own
  `Task <N>: complete (...)` line. Readers that match
  `^Task\s+(\d+)([a-z]?):\s*complete` must keep working.
- Skill edits follow superpowers:writing-skills (RED baseline, then GREEN).
- Plan files keep their current shape. No new plan syntax.

## Approaches

| Approach | Trade-off | Picked |
|---|---|---|
| Fork superpowers, edit SDD text and scripts, pin to the fork's tag | One source of truth, testable; carries a rebase each upstream bump | **Yes** |
| Upstream PR only, stay on v7.0.2 until merged | No maintenance; no control over timing or acceptance | No |
| Overlay rule in `~/.claude/rules` or a mattstack skill | Fastest; contradicts SDD in ~5 places and the scripts stay single-task | No |

Where to cut, considered separately:

| Cut | Trade-off | Picked |
|---|---|---|
| Execution groups consecutive tasks | Plans stay fine-grained; controller decides with cross-task view | **Yes** |
| Plans write bigger tasks | Fewer tasks, coarser tracking, no execution change | No |
| Plan writer tags groups | Plan author knows coupling best; new plan syntax | No |
| Batched reviews only | Saves reviewers, implementers still cold-start per task | No |

Grouping rule, considered: shared files + size cap (**picked**), risk only
(groups can sprawl across unrelated code), fixed-size waves (pairs unrelated
tasks, bundles risky with trivial).

## Decided design

### Drawing groups (pre-flight)

The controller draws groups once, right after the pre-flight conflict scan,
using the scan's shared-file/shared-interface table it already builds.

- A group is a run of **consecutive** tasks in plan order.
- Tasks join a group only when each shares a file or a produced/consumed
  interface with another task in the group.
- Cap: **3 tasks** per group.
- A task that needs the most capable model tier (per Model Selection: design
  judgment or broad codebase understanding) always runs alone.
- Tasks with no qualifying neighbor run alone, exactly as today.
- Each group is ledgered before Task 1 dispatches:
  `Group <G>: tasks <N>,<N+1>,<N+2> — <shared file or interface>`.

### Running a group

- **Brief:** the controller runs `task-brief` once per task in the group, as
  today, and hands the implementer every brief path in order. No new brief
  format.
- **Implementer:** one dispatch for the group. It works the tasks in order,
  with each task's own test cycle and **one commit per task at minimum**. One
  report file for the group, with a section per task.
- **Model tier:** the highest tier any member task would get on its own.
- **Review:** one task-review dispatch over the group's whole range
  (`review-package PLAN BASE HEAD`, BASE recorded before the group's
  implementer). The reviewer gets every brief path, the report file and the
  package. It returns a spec verdict **per task** and one quality verdict for
  the group.
- **Fix loop:** unchanged rules, applied to the group as the unit. Five-round
  cap per group. Findings name the task they belong to.
- **Completion:** one `Task <N>: complete (group <G>, commits <a7>..<b7>,
  review clean)` line per member task, written together. Parked counts go on
  the line of the task each parked finding names.

### Ledger lines (my call)

Group-scoped lines use a `Group <G>:` prefix. Both known ledger readers
(`lib/progress/ledger.ts` in rt and `mattstack:work-progress`) key only on
`^Task\s+(\d+)([a-z]?):\s*complete` and read the latest line as "now", so
`Group` lines are invisible to their counts and harmless as the latest line.

- `Group <G>: tasks <N>,<N+1>,<N+2> — <shared file or interface>` (drawn)
- `Group <G>: dispatched, base <sha7>` (implementer dispatched)
- `Group <G>: implemented <a7>..<b7>` (implementer reported DONE)
- `Group <G>: fix round <R>/5 (...)`, replacing the per-task fix-round line
  for grouped tasks; findings inside it name their task.
- Minor and parked lines stay keyed `Task <N>:`, naming the task the finding
  belongs to.
- A task that runs alone keeps today's lines exactly.

Resuming (`references/resuming.md`): a group with a `dispatched` line and no
`implemented` line resumes its implementer from the report file and the
commits since its base; one with `implemented` and no completion lines
resumes at review or at the next fix round. Nothing completed is
re-dispatched.

### Partial outcomes (my call)

- **Implementer blocked partway** (BLOCKED or NEEDS_CONTEXT on a later task):
  the tasks it finished go to review as a smaller group; the blocked task is
  handled per `references/handling-reports.md` and then runs alone.
  `handling-reports.md` gains that sentence.
- **Review passes some tasks and fails others:** the fix loop runs on the
  group, and all member completion lines wait for it. Fix loops almost always
  end in one round, so splitting is not worth the bookkeeping.

### Batching (my call)

`references/batching.md` stays as it is: small same-shape edits may still go
to one subagent past the 3-task cap and the consecutive rule, because
repeated identical edits stay reviewable at any count. Batched tasks also get
per-task completion lines. Grouping is the separate rule for related,
different-shaped tasks.

### Skill size (my call)

`SKILL.md` is 19,740 bytes and `tests/skill-size/test-skill-size.sh` fails at
20,000. The grouping, overlap and ledger rules go in a new
`references/task-groups.md`; `SKILL.md` gets short pointers and trims to stay
under the cap.

### Overlap

- When group G's implementer reports DONE and its review is dispatched, the
  controller may dispatch group G+1's implementer at once **if G+1's planned
  files (the plan's Files blocks) do not overlap G's files**.
- Ledger the decision: `Ruling: G+1 dispatched during G's review — files
  disjoint — cost if wrong: rework of G+1`.
- **One group ahead, no further** (Matt's call). G+2 never dispatches until
  every task in G has its completion line. G+1's review may run while G's fix
  round runs; reviewers do not touch code.
- At most one implementer runs at a time. If G's review needs a fix round
  while G+1's implementer is running, the fix round waits until G+1's
  implementer reports.
- G+1's BASE is recorded at its dispatch, before any G fix commits, so its
  review range stays clean.
- FIX_BASE for a fix round is `HEAD` at the moment the fix is dispatched,
  not the head G's review saw. Otherwise G+1's commits, landed in between,
  would fall inside G's scoped re-review. Without overlap the two are the
  same commit, so the rule is uniform.
- When G's review finds a problem that G+1 built on (an interface G+1
  consumes), the controller rules per the fix loop's breaker guidance and
  carries the ruling into G+1's next fix round or review.

### Files to change

- `skills/subagent-driven-development/SKILL.md`: core principle, process
  graph, task-loop wording, "never dispatch multiple implementation subagents
  in parallel" (stays true: one implementer at a time), the new grouping and
  overlap sections, the completion format, rationalization rows.
- `references/preflight.md`: drawing groups after the scan.
- `references/resuming.md`: a group whose member tasks are not all complete
  resumes as a group; a ledgered group line binds the resume.
- `references/fix-loop.md`: group as the unit; FIX_BASE recorded at fix
  dispatch.
- `references/task-groups.md` (new): drawing groups, running them, overlap,
  ledger lines, partial outcomes.
- `references/handling-reports.md`: the partial-group sentence.
- `references/batching.md`: one line distinguishing it from grouping, and
  per-task completion lines.
- `implementer-prompt.md`, `task-reviewer-prompt.md`: multiple briefs,
  per-task sections and verdicts.
- `skills/writing-plans/SKILL.md`: the execution-handoff blurb for
  Subagent-driven ("a fresh subagent implements each task") mentions groups.

### Shipping (Matt's call)

The plan's last task is a hand-off checklist the session runs after the SDD
run and final review, asking Matt before each external step:

1. Create the public fork `m4ttstack/superpowers` on GitHub.
2. Bump the plugin version to `7.0.2-groups.1` with `scripts/bump-version.sh`
   so the installed plugin cache refreshes.
3. Push branch `sdd-task-groups` and tag `v7.0.2-groups.1` to the fork.
4. Point `~/.claude/local-marketplaces/superpowers-pinned/.claude-plugin/marketplace.json`
   at the fork's URL and tag, then `/reload-plugins`.

These are not SDD tasks: they are shared-remote side effects that stop a
running plan.

## Left to the builder

- Exact skill wording, process-graph shape, and where sections sit.
- Whether `task-brief` gains a multi-task convenience mode; not required.
- RED/GREEN scenario design for writing-skills, within this outline: a
  9-task plan where tasks 2-4 share a file and task 6 needs design judgment.
  RED: today's skill dispatches 9 implementers. GREEN: groups {2,3,4}, task 6
  alone, per-task completion lines, overlap ruling ledgered where files are
  disjoint.
- Whether `tests/sdd-helper-paths` needs a case.
