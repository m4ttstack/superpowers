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

- a task that needs the most capable tier (Model Selection: design
  judgment or broad codebase understanding);
- a task with no `**Files:**` block, or one whose paths you cannot pin down:
  you cannot prove what it shares, so it neither joins a group nor overlaps
  another;
- a task that shares nothing with its neighbors.

A group's id is its first task's number. Before dispatching Task 1, write
one ledger line per group of two or more:

`Group <G>: tasks <N>,<N+1>[,<N+2>] — <the shared file or interface>`

Tasks running alone get no `Group` line and run exactly as the rest of this
skill describes for a single task.

## Running a group

A group moves through the task loop as one unit:

- **Briefs:** run `task-brief` once per member task, as for a single task.
  The dispatch's `[BRIEF_FILES]` lists every brief path in plan order; no
  combined brief.
- **Implementer:** one dispatch for the whole group, on the highest tier any
  member would get alone. It works the tasks in order, each with its own
  test cycle and at least one commit, and writes one report file with a
  `## Task <N>` section per task.
- **Review:** record BASE before the dispatch, build one review package over
  BASE..HEAD, and dispatch one task reviewer with every brief, the report,
  and the package. It returns a spec verdict per task and one quality
  verdict for the group.
- **Fix loop:** the group is the unit (see fix-loop.md); every finding names
  the task it belongs to.
- **Completion:** when the review is clean, or every open finding is parked
  at the cap, write one line per member task, together:
  `Task <N>: complete (group <G>, commits <base7>..<head7>, review clean)`.
  A parked finding counts on the line of the task it names:
  `Task <N>: complete (group <G>, commits <base7>..<head7>, <K> parked)`.
  Never one combined line for the group: ledger readers count
  `Task <N>: complete` lines.

## Partial outcomes

- **The implementer finishes some tasks, then reports BLOCKED or
  NEEDS_CONTEXT on a later one:** review the finished tasks as a smaller
  group. Handle the stuck task per handling-reports.md, then run it alone.
- **The review passes some tasks and fails others:** the fix loop runs on
  the whole group, and every member's completion line waits for it. Fix
  loops almost always end in one round, so splitting the group is not worth
  its bookkeeping.
