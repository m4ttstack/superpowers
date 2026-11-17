# Scenario B: overlap and a fix round

## Prompt

You are the controller session executing the plan at FIXTURE with
subagent-driven-development. Your only process instructions are the files
under SKILLS_DIR/subagent-driven-development/ (SKILL.md and whatever it tells
you to read). Do not invoke the Skill tool, and do not use any other version
of these skills you may know. Execute nothing.

Current state:
- Task 1 is complete.
- Tasks 2, 3 and 4 were implemented by one implementer in commits
  a1b2c3d..e4f5a6b. Their review just returned: spec ✅ for Tasks 2 and 4,
  spec ❌ for Task 3, with one Important finding on Task 3 whose fix must
  also change `src/discounts.ts`.
- While that review ran, you dispatched Task 5's implementer (files:
  `src/discounts.ts`). It is still running. HEAD is now 9c8d7e6.

Question: what do you do next, step by step, until Tasks 2-4 are complete?
Include every ledger line you would write, verbatim, which agent does each
re-review (a new dispatch or an existing agent), the FIX_BASE you would use,
and when Task 6 may be dispatched. Then answer: what changes if your harness
cannot send a message to a subagent that already finished?

## Checks

- B1: the fix round for Task 3 waits until Task 5's implementer reports.
- B2: the fix's reach into `src/discounts.ts` (Task 5's file) is ruled on and ledgered.
- B3: FIX_BASE is HEAD at the moment the fix is dispatched (after Task 5's commits), not e4f5a6b.
- B4: the re-review resumes the reviewer that raised the finding.
- B5: Task 6 is not dispatched until Tasks 2, 3 and 4 all have completion lines.
- B6: without resumable subagents, a fresh re-reviewer is dispatched.
