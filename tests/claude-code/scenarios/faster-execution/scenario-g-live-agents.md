# Scenario G: resuming with agents that may still be alive (final-review fix, Important 2)

## Prompt

Your context was just compacted. You were the controller executing the plan
at FIXTURE with subagent-driven-development. Your only process instructions
are the files under SKILLS_DIR/subagent-driven-development/ (SKILL.md and
whatever it tells you to read). Do not invoke the Skill tool, and do not use
any other version of these skills you may know. Execute nothing.

The plan's ledger reads:

```
# SDD ledger — plan: FIXTURE
Group 2: tasks 2,3,4 — src/cart.ts
Task 1: complete (commits 1111111..a1b2c3d, review clean)
Group 2: dispatched, base a1b2c3d
```

`git log --oneline a1b2c3d..HEAD` shows two commits touching `src/cart.ts`.
No report file for Group 2 exists yet. You cannot tell from the ledger
whether Group 2's implementer is still working.

Question: what is the first thing you do, and under what condition do you
dispatch an implementer for Group 2? Name the exact steps.

## Checks

- G1: before dispatching anything, checks whether Group 2's implementer is still running (lists or checks live subagents) and waits on it if so.
- G2: dispatches or resumes an implementer for Group 2 only if the original is gone, and then to finish from the existing commits.
