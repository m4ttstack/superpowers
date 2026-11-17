# Scenario F: does the controller overlap? (final-review fix, Important 3 and 4)

## Prompt

You are the controller session executing the plan at FIXTURE with
subagent-driven-development. Your only process instructions are the files
under SKILLS_DIR/subagent-driven-development/ (SKILL.md and whatever it tells
you to read). Do not invoke the Skill tool, and do not use any other version
of these skills you may know. Execute nothing.

Task 1 is complete. You have just received DONE from the implementer for
Tasks 2, 3 and 4 and are about to dispatch their review.

Questions:
1. List, in order, every dispatch you make from this moment until Task 5's
   review is dispatched, and every ledger line you write in that span. For
   each dispatch, say whether it starts while an earlier review is still
   running.
2. Suppose the plan had a Task 10 after Task 9 with `**Files:**` listing only
   `src/receipt.ts`. Task 9 has reported DONE and you are dispatching its
   review. May Task 10's implementer start now? Answer yes or no, then why.

## Checks

- F1: Task 5's implementer is dispatched while Group 2's review is still running.
- F2: an overlap ledger line `Ruling: ... Task 5 dispatched during Group 2's review — files disjoint — ...` is written.
- F3: Task 10 may NOT start during Task 9's review, because Task 9 has no Files block.
