# SDD ledger — plan: docs/plans/sample.md
Group 2: tasks 2,3,4 — src/cart.ts
Group 6a: tasks 6a,6b — src/format.ts
Task 1: dispatched, base 1111111
Task 1: implemented 1111111..a1b2c3d
Task 1: review full (reviewer agent-r1)
Task 1: complete (commits 1111111..a1b2c3d, review clean)
Group 2: dispatched, base a1b2c3d
Group 2: implemented a1b2c3d..e4f5a6b
Group 2: review full (reviewer agent-r2)
Ruling: Task 5 dispatched during Group 2's review — files disjoint — cost if wrong: rework of Task 5
Task 5: dispatched, base e4f5a6b
Task 5: implemented e4f5a6b..9c8d7e6
Group 2: fix round 1/5 (1 addressed, 0 open — Task 3: unknown SKU throws; commits 9c8d7e6..0aa1bb2)
Task 3: minor (deferred): removeItem could return a boolean
Task 2: complete (group 2, commits a1b2c3d..e4f5a6b + 9c8d7e6..0aa1bb2, review clean)
Task 3: complete (group 2, commits a1b2c3d..e4f5a6b + 9c8d7e6..0aa1bb2, review clean)
Task 4: complete (group 2, commits a1b2c3d..e4f5a6b + 9c8d7e6..0aa1bb2, review clean)
Task 5: review full (reviewer agent-r3)
Ruling: Group 6a dispatched during Task 5's review — files disjoint — cost if wrong: rework of Group 6a
Group 6a: dispatched, base 0aa1bb2
Task 5: complete (commits e4f5a6b..9c8d7e6, review clean)
Group 6a: implemented 0aa1bb2..5ee6ff7
Group 6a: review light (reviewer agent-r4)
Task 6a: complete (group 6a, commits 0aa1bb2..5ee6ff7, review clean)
Task 6b: complete (group 6a, commits 0aa1bb2..5ee6ff7, review clean)
