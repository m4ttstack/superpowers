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
