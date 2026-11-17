# Faster Plan Execution Design

Two phases, one fork:

- **Phase 1, subagent-driven-development (SDD):** task groups, one-ahead
  overlap, resumed reviewers, review depth by risk, targeted tests.
- **Phase 2, a new execution mode:** the session implements, a fresh
  reviewer checks each group.

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

So the time sink is cold starts: every fresh agent re-reads the codebase
before doing useful work, and SDD spends at least two per task. Current
models hold far more context and need fewer turns than the skill assumes.
Independence matters for review; it matters much less for implementation.

This change lets the controller run consecutive related tasks as one
**group**: one implementer, one review over the group's diff. The next
group's implementer may start while the previous group's review runs, when
their files do not overlap. Re-reviews resume the reviewer instead of
spawning a fresh one, transcription work gets a lighter review, and test
runs scope to what changed. Phase 2 adds a mode that drops implementer
subagents entirely and keeps the per-group reviews.

## Goals

- Fewer agent seats per plan where tasks are related: a 3-task group costs 2
  seats instead of 6; in Phase 2's mode, 1.
- Less wall-clock on long plans, from grouping, overlap, cheaper reviews of
  transcription work, and fewer full-suite runs.
- Keep one independent review over every line of code before the final
  review, in every mode except today's native mode.

## Non-goals

- Changing how writing-plans sizes tasks. Plans stay fine-grained; grouping
  is an execution-time decision.
- Changing the fix loop's caps, the final whole-branch review, or the four
  stop conditions.
- Parallel implementers. At most one implementer is active at a time.
  Parallel worktrees for independent groups are a later, separate pass.
- Thinner plans. writing-plans keeps its step detail; slimming it is a
  separate pass.
- Changing today's native mode (`executing-plans` with one final review).
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

Further speedups, considered (Matt picked the first four):

| Lever | Trade-off | Picked |
|---|---|---|
| Resume the reviewer for re-reviews | Cheap; the reviewer is less "fresh" on round 2+ | **Yes** |
| Review depth by risk | Faster reviews of transcription work; relies on the final review as net | **Yes** |
| Targeted tests, full suite once per group | Fewer suite runs; cross-task breakage surfaces at group end | **Yes** |
| Session implements, fresh reviewer per group | Biggest seat cut; session context carries every task | **Yes, Phase 2** |
| Thinner plans | Shorter planning; implementers decide more | Later |
| Parallel worktrees for independent groups | Biggest wall-clock win on wide plans; merge cost, biggest change | Later |
| Mid-tier floor for implementers | Fewer retry turns; higher token price | No |

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

### Resumed reviewers

- A fix round's scoped re-review resumes the reviewer agent that raised the
  findings: send it the fix package path and the re-review instructions
  (`re-review-prompt.md`'s content). It already holds the diff, the briefs
  and its own findings.
- Record the reviewer's agent identity from its dispatch, as the implementer's
  is recorded today.
- This holds in rounds 4-5 too, when a fresh escalated implementer takes
  over: the findings' author judges whether they are addressed.
- A harness that cannot message a live subagent dispatches a fresh
  re-reviewer, as today.

### Review depth by risk (my call on the details)

- A group is **transcription** when every member task's plan text carries
  the complete code for every code step (the signal Model Selection already
  uses for the cheapest implementer tier) and the implementer reports DONE
  with green tests.
- A transcription group gets a **light review**: the same task-reviewer
  prompt and inputs, on the cheapest tier, returning the per-task spec
  verdicts and Critical findings only. The mid-tier reviewer floor exists
  because cheap models take more turns on multi-step work; a light review is
  one package read and a verdict, so the floor does not apply.
- Any spec ❌ or Critical from a light review enters the fix loop as usual;
  its re-reviews are scoped re-reviews, as today.
- Every other group gets today's full review.
- Ledger the depth with the review: `Group <G>: review light` or
  `Group <G>: review full`. A task running alone uses `Task <N>: review
  light|full`.

### Targeted tests

- While working a task, the implementer runs only the tests covering what it
  changed, before each commit.
- The full suite runs once per group, after the last task's commit and
  before the report. A task running alone is a group of one, so today's
  "full suite once before committing" stays for it.
- The final whole-branch review keeps its full-suite run.
- `implementer-prompt.md`'s "run the full suite once before committing"
  becomes the per-group rule.

### Files to change

- `skills/subagent-driven-development/SKILL.md`: core principle, process
  graph, task-loop wording, "never dispatch multiple implementation subagents
  in parallel" (stays true: one implementer at a time), the new grouping and
  overlap sections, the completion format, rationalization rows.
- `references/preflight.md`: drawing groups after the scan.
- `references/resuming.md`: a group whose member tasks are not all complete
  resumes as a group; a ledgered group line binds the resume.
- `references/fix-loop.md`: group as the unit; FIX_BASE recorded at fix
  dispatch; re-reviews resume the reviewer.
- `re-review-prompt.md`: usable as a follow-up message to a resumed
  reviewer as well as a fresh dispatch.
- Model Selection in `SKILL.md`: the light-review exception to the mid-tier
  reviewer floor.
- `references/task-groups.md` (new): drawing groups, running them, overlap,
  ledger lines, partial outcomes.
- `references/handling-reports.md`: the partial-group sentence.
- `references/batching.md`: one line distinguishing it from grouping, and
  per-task completion lines.
- `implementer-prompt.md`: multiple briefs, per-task report sections,
  targeted tests per task and the full suite once per group.
- `task-reviewer-prompt.md`: multiple briefs, per-task spec verdicts, and
  the light-review variant (spec verdicts and Critical only).
- `skills/writing-plans/SKILL.md`: the execution-handoff blurb for
  Subagent-driven ("a fresh subagent implements each task") mentions groups.

## Phase 2: session implements, fresh reviewers check

A third execution mode beside Subagent-driven and Native. The session works
every task itself, as Native does, and dispatches a fresh reviewer per group,
as SDD does. It cuts every implementer cold start and keeps the independent
per-group review.

### Decided

- Lives in `executing-plans` as a variant chosen at the plan handoff, not a
  new skill: Native already owns the session-implements loop, the shared
  ledger and workspace, `task-start` and `task-done`. `executing-plans`'
  `SKILL.md` is 18,364 bytes, so the variant's rules go in a new
  `skills/executing-plans/references/group-reviews.md` with a short pointer.
- Groups are drawn exactly as Phase 1 draws them, after the pre-flight scan,
  and ledgered the same way.
- After each group's last commit and full-suite run, the session writes a
  short report file (per-task sections: what changed, tests run, concerns)
  and dispatches SDD's `task-reviewer-prompt.md` with the briefs, that report
  and the review package. Review depth by risk applies.
- **Overlap:** while group G's reviewer runs, the session may start group
  G+1 if their files do not overlap. One group ahead, as in Phase 1.
- **Fix loop:** the session fixes findings itself (it is the implementer) and
  the resumed reviewer re-reviews. Three rounds maximum. Findings still open
  after round 3 are parked with a ruling and pointed out to the final review;
  the session never adjudicates its own code below that cap.
- Completion lines per task, `Group <G>:` lines, and resume rules match
  Phase 1, so a plan can switch executors mid-flight.
- The final whole-branch review stays on the most capable tier.
- `writing-plans`' handoff offers three options. My draft wording for the
  new one: "**Native with reviews:** I implement every task myself, and a
  fresh reviewer checks each group of related tasks before I move past it,
  then one whole-branch review at the end. Fast, with an independent check
  along the way."

### Left to the builder (Phase 2)

- Which option the handoff recommends in which situations.

### Shipping (Matt's call)

The plan's last task is a hand-off checklist the session runs after the SDD
run and final review, asking Matt before each external step:

1. Create the public fork `m4ttstack/superpowers` on GitHub.
2. Bump the plugin version to `7.0.2-groups.1` with `scripts/bump-version.sh`
   so the installed plugin cache refreshes.
3. Push branch `sdd-task-groups` and tag `v7.0.2-groups.1` to the fork.
4. Point `~/.claude/local-marketplaces/superpowers-pinned/.claude-plugin/marketplace.json`
   at the fork's URL and tag, then `/reload-plugins`.
5. Update `~/.claude/rules/subagent-execution-default.md` so the standing
   default is Native with reviews (Matt's call), with subagent-driven kept for
   when he asks for it or a plan is long enough to compact mid-run.

These are not SDD tasks: they are shared-remote side effects that stop a
running plan.

## Left to the builder

- Exact skill wording, process-graph shape, and where sections sit.
- Whether `task-brief` gains a multi-task convenience mode; not required.
- RED/GREEN scenario design for writing-skills, within this outline: a
  9-task plan where tasks 2-4 share a file and task 6 needs design judgment.
  RED: today's skill dispatches 9 implementers. GREEN: groups {2,3,4}, task 6
  alone, per-task completion lines, overlap ruling ledgered where files are
  disjoint, a light review on a transcription group, a fix round that resumes
  the reviewer. Phase 2 gets its own scenario on the same plan: no
  implementer dispatches, one reviewer per group, the session continuing on
  the next disjoint group while a review runs.
- Whether `tests/sdd-helper-paths` needs a case.
