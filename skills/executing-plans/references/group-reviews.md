# Native with Reviews

Part of superpowers:executing-plans. Read it before Task 1 when your human
partner chose **Native with reviews**: you implement every task yourself,
and a fresh reviewer checks each group of related tasks before you move
past it.

Why: implementer subagents each re-read the codebase from zero, and you
already hold the plan and the code. Review is where a fresh context earns
its cost, so this variant keeps the per-group review and drops every
implementer dispatch.

## What changes from Native

Everything in SKILL.md still holds (ledger, briefs, TDD, `task-start`,
`task-done`, the final whole-branch review), plus:

1. **Draw groups at pre-flight** exactly as subagent-driven-development
   does: read
   [../../subagent-driven-development/references/task-groups.md](../../subagent-driven-development/references/task-groups.md),
   sections Drawing groups and Ledger lines, and write the `Group` lines
   before Task 1. A task running alone is a group of one.
2. **Work a group's tasks in order,** each with its own TDD cycle and
   commit, reading every step's output as SKILL.md says. Hold `task-done`
   until step 8: its completion line means reviewed, so it waits for the
   review. Before the group's first task, ledger `Group <G>: dispatched,
   base <HEAD7>` (a task alone: `Task <N>: dispatched, base <HEAD7>`), the
   same line subagent-driven-development writes, so either executor can
   resume this ledger.
3. **After the group's last task,** run the full suite once, write a short
   report file in the workspace (`group-<G>-report.md`, or
   `task-<N>-report.md` alone): one `## Task <N>` section per task with what
   changed, the tests you ran with their output, and any concerns. Ledger
   `Group <G>: implemented <base7>..<head7>` (alone: `Task <N>:
   implemented ...`).
4. **Dispatch one reviewer per group** with
   [../../subagent-driven-development/task-reviewer-prompt.md](../../subagent-driven-development/task-reviewer-prompt.md):
   every brief, your report file, and the package that
   `../../subagent-driven-development/scripts/review-package PLAN_FILE BASE HEAD`
   prints (run it by its absolute path, from the working tree you're
   executing in).
   Pick `[REVIEW_DEPTH]` and the tier per task-groups.md, Review depth.
   Ledger `Group <G>: review light|full (reviewer <agent id>)` (alone:
   `Task <N>: review ...`); the id on that line is how you resume the
   reviewer after compaction.
5. **Keep working while it reviews,** one group ahead and no further: start
   the next group only if both it and the group under review have
   `**Files:**` blocks with pinned paths and they share no file, and ledger
   `Ruling: <G+1> started during <G>'s review — files disjoint — cost if
   wrong: rework of <G+1>`. Otherwise wait for the verdict. Never start G+2 until every task in G has its completion line.
6. **When findings come back,** route them as
   [../../subagent-driven-development/references/fix-loop.md](../../subagent-driven-development/references/fix-loop.md)
   does before its loop starts: each Minor becomes `Task <N>: minor
   (deferred): <one-liner>` and is never fixed here; a ⚠️ item goes through
   [../../subagent-driven-development/references/cannot-verify.md](../../subagent-driven-development/references/cannot-verify.md);
   spec ❌, Critical, Important, and confirmed ⚠️ gaps enter the loop. For
   those, you are the implementer: finish the group you are on (through its
   last task's commit), so its review range stays free of fix commits, then
   fix them, re-run the covering tests, and append a fix report. Record FIX_BASE (HEAD) when you start the fix. Send the resumed
   reviewer the body of
   [../../subagent-driven-development/re-review-prompt.md](../../subagent-driven-development/re-review-prompt.md)
   with the fix package; a harness that cannot message a finished subagent
   dispatches a fresh re-reviewer. Ledger
   `Group <G>: fix round <R>/3 (...)` (alone: `Task <N>: fix round ...`).
7. **Three rounds at most.** If findings are still open after round 3, stop
   fixing: park each as `Task <N>: parked — <finding> — Ruling: <why it
   stands for now> — <cost if wrong>` and name it to the final reviewer.
   You never rule your own code acceptable before the cap, and the cap
   hands the call to the final review, not to you.
8. **Complete the group** once the review is clean or every open finding
   is parked: run `task-done` for each member task in order, with the BASE
   that task's `task-start` printed and its covering test command. Each
   gets its own `Task <N>: complete (commits ..., tests: ...)` line in
   `task-done`'s format; that line is the completion line, and parked
   findings are counted by their `parked` lines, not on it.

The final whole-branch review and its single fix pass run as SKILL.md
describes, with the parked findings in front of the reviewer.

## Without a subagent tool

The per-group reviews cannot run. Execute as plain Native (SKILL.md, the
self-review path for the final review), ledger `Ruling: Native with reviews
ran as Native — no subagent tool — cost if wrong: no independent review
until the end`, and say so in your final message.

## Resuming

A task inside a group gets its completion line only after the group's
review, so SKILL.md's "resume at the first task without a completion line"
would redo committed work. Resume from the `Group` and `Task <N>:
dispatched|implemented` lines instead, per
[../../subagent-driven-development/references/resuming.md](../../subagent-driven-development/references/resuming.md):
`dispatched` without `implemented` means you were mid-group (finish from the
commits since its base); `implemented` without completion lines means
resume at the review, or at the next fix round if one is ledgered.
