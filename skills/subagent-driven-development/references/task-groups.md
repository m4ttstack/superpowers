# Task Groups

Part of superpowers:subagent-driven-development. Read it at pre-flight, and
again whenever you dispatch, review, or complete a group.

Every fresh subagent re-reads the codebase before it does useful work. A
group runs consecutive related tasks through ONE implementer and ONE review,
so a three-task group costs two seats instead of six. The review stays
independent; only the cold starts go.

## Drawing groups

Draw groups once, right after the pre-flight table, from the table's
shared-file and shared-interface rows. Walk the plan in order and build each
group like this:

1. Start a group at the next task not yet placed.
2. Add the task after it when it shares a file (its `**Files:**` block) or a
   produced/consumed interface (its `**Interfaces:**` block) with a task
   already in the group.
3. Stop at three tasks, or at the first task that shares nothing.

Three kinds of task always run alone, as a group of one:

- a task that needs the most capable tier (Model Selection: architecture
  and design tasks);
- a task with no `**Files:**` block, or one whose paths you cannot pin down:
  you cannot prove what it shares, so it neither joins a group nor overlaps
  another;
- a task that shares nothing with its neighbors.

A group's id is its first task's id (`2`, or `6a` for a group starting
at Task 6a). Before dispatching Task 1, write one ledger line per group of
two or more:

`Group <G>: tasks <N>,<N+1>[,<N+2>] — <the shared file or interface>`

Tasks running alone get no `Group` line. They run as the rest of this skill
describes for a single task, plus the `Task <N>:` dispatched, implemented,
and review lines in Ledger lines, which resuming needs.

## Running a group

A group moves through the task loop as one unit:

- **Briefs:** run `task-brief` once per member task, as for a single task.
  The dispatch's `[BRIEF_FILES]` lists every brief path in plan order; no
  combined brief.
- **Implementer:** one dispatch for the whole group, on the highest tier any
  member would get alone. It works the tasks in order, each with its own
  test cycle and at least one commit, and writes one report file,
  `group-<G>-report.md` in the workspace, with a `## Task <N>` section per
  task.
- **Review:** record BASE before the dispatch, build one review package over
  BASE..HEAD, and dispatch one task reviewer with every brief, the report,
  and the package. It returns a spec verdict per task and one quality
  verdict for the group. Write the reviewer's agent id on its review ledger
  line (Ledger lines): re-reviews resume it, and the ledger is what
  survives compaction.
- **Fix loop:** the group is the unit (see fix-loop.md); every finding names
  the task it belongs to.
- **Completion:** when the review is clean, or every open finding is parked
  at the cap, write one line per member task, together:
  `Task <N>: complete (group <G>, commits <base7>..<head7>, review clean)`,
  where the range is the group's `implemented` range. When overlap put
  another unit's commits before a fix round, list each fix round's range
  after it: `commits <base7>..<head7> + <fixbase7>..<fixhead7>`.
  A parked finding counts on the line of the task it names:
  `Task <N>: complete (group <G>, commits <base7>..<head7>, <K> parked)`.
  Never one combined line for the group: ledger readers count
  `Task <N>: complete` lines.

### Review depth

Pick the depth when you dispatch the review, and ledger it beside the
review: `Group <G>: review light|full` (a task running alone:
`Task <N>: review light|full`).

- **Light,** when the work is transcription: every member task's plan text
  carries the complete code for every code step (the same signal that puts
  its implementer on the cheapest tier), and the implementer reported DONE
  with green tests. Dispatch the task reviewer with `[REVIEW_DEPTH]` set to
  `light`, on the cheapest tier. It returns the spec verdict per task and
  Critical findings only. A light review is one package read and a verdict,
  so the mid-tier reviewer floor (Model Selection) does not apply.
- **Full,** for everything else: today's review, `[REVIEW_DEPTH]` set to
  `full`.

A light review's spec ❌ or Critical finding enters the fix loop like any
other; its re-reviews are scoped re-reviews.

## Partial outcomes

- **The implementer finishes some tasks, then reports BLOCKED or
  NEEDS_CONTEXT on a later one:** review the finished tasks as a smaller
  group. Handle the stuck task per handling-reports.md, then run it alone.
  The tasks after it wait for it, then are drawn again per Drawing groups.
  Ledger the split: `Ruling: Group <G> split — <finished tasks> reviewed
  as Group <G>, Task <N> alone, <later tasks> redrawn — <why> — cost if
  wrong: one extra review seat`.
- **The review passes some tasks and fails others:** the fix loop runs on
  the whole group, and every member's completion line waits for it. Fix
  loops almost always end in one round, so splitting the group is not worth
  its bookkeeping.

## Overlap: one group ahead

When group G's implementer reports DONE and you dispatch G's review, you
may dispatch the next group's implementer (G+1, a group or a lone task) at
once, if:

- G and G+1 both have `**Files:**` blocks with pinned paths, and
- no file appears in both.

Ledger it: `Ruling: <G+1> dispatched during <G>'s review — files disjoint —
cost if wrong: rework of <G+1>`.

The limits:

- **One group ahead, no further.** G+2 never dispatches until every task in
  G has its completion line.
- **One implementer at a time.** A fix round for G waits until G+1's
  implementer reports. Reviewers may overlap: G+1's review can run while
  G's fix round runs.
- **BASE and FIX_BASE are recorded at dispatch.** G+1's BASE is HEAD when
  G+1 is dispatched. A fix round's FIX_BASE is HEAD when the fix is
  dispatched (fix-loop.md), so G+1's commits never fall inside G's scoped
  re-review.
- **A fix that reaches into G+1's files** (the finding cannot be fixed
  without them): rule on it and ledger the ruling before the fix round,
  tell G's implementer what G+1 put in those files, and point G+1's review
  or next fix round at the overlap.
- **A finding G+1 built on** (an interface G+1 consumes changes): rule per
  the fix loop's breaker guidance and carry the ruling into G+1's review or
  next fix round.

## Ledger lines

A group writes these lines, in this order, beside the single-task lines the
rest of this skill describes. `<G>` is the group's first task's id.

| When | Line |
|---|---|
| Pre-flight | `Group <G>: tasks <N>,<N+1>[,<N+2>] — <shared file or interface>` |
| Implementer dispatched | `Group <G>: dispatched, base <base7>` |
| Implementer reported DONE | `Group <G>: implemented <base7>..<head7>` |
| Review dispatched | `Group <G>: review light (reviewer <agent id>)` or `Group <G>: review full (reviewer <agent id>)` |
| Overlap dispatch | `Ruling: <G+1> dispatched during <G>'s review — files disjoint — cost if wrong: rework of <G+1>` |
| Each fix round | `Group <G>: fix round <R>/5 (<X> addressed, <Y> open — Task <N>: <finding>; commits <a7>..<b7>)` (`/3` under executing-plans' Native with reviews) |
| Clean, or parked at the cap | one `Task <N>: complete (group <G>, ...)` line per member task |

Minor, parked, and ruling lines stay keyed `Task <N>:` and name the task
the finding belongs to. A task running alone writes `Task <N>: dispatched,
base <base7>`, `Task <N>: implemented <base7>..<head7>`, and `Task <N>:
review light|full (reviewer <agent id>)`, and otherwise keeps the
single-task lines. No `Group` line ever says `complete`: readers count
`Task <N>: complete` lines and nothing else.
