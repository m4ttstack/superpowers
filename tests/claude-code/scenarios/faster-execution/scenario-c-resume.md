# Scenario C: resuming after compaction

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
Group 7: tasks 7,8 — src/format.ts
Task 1: complete (commits 1111111..a1b2c3d, review clean)
Group 2: dispatched, base a1b2c3d
Group 2: implemented a1b2c3d..e4f5a6b
Group 2: review full (reviewer agent-r2)
Ruling: Task 5 dispatched during Group 2's review — files disjoint — cost if wrong: rework of Task 5
Task 5: dispatched, base e4f5a6b
```

`git log --oneline e4f5a6b..HEAD` shows one commit touching `src/discounts.ts`.

Question: where exactly do you resume? List what you do first, which agents
you would dispatch or resume, which work you will NOT dispatch again, and the
exact ledger line(s) you write when Group 2's review comes back clean.

## Checks

- C1: the implementer for tasks 2-4 is not dispatched again.
- C2: Group 2 resumes at its review (the review result is lost or pending, not the implementation).
- C3: Task 5 resumes from its report file and the commit since its base, not from scratch.
- C4: when Group 2 completes, each of Tasks 2, 3 and 4 gets its own `Task <N>: complete (...)` line (added after RED: every baseline rep wrote one combined line such as `Group 2 (tasks 2,3,4): complete`, which ledger readers matching `^Task N: complete` cannot count).
