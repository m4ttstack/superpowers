# Scenario results: faster plan execution

Runs: opus / medium, 3 reps per variant. A check passes only when all 3 reps pass.

## RED (v7.0.2 baseline)

| Check | Result | Quote from a failing rep |
|---|---|---|
| A1 groups | FAIL 3/3 | "implementer \| Task 2 ... implementer \| Task 3 ... implementer \| Task 4" (18 dispatches; rep 3 batched 7+8 via batching.md only) |
| A2 6 and 9 alone | pass 3/3 | concern: passes trivially, every task runs alone on baseline |
| A3 Group line | FAIL 3/3 | no `Group` lines in any rep |
| A4 one implementer + one reviewer for 2-4 | FAIL 3/3 | three implementers, three reviewers |
| A5 light review for 7-8 | FAIL 3/3 | "task reviewer \| Task 7 \| mid-tier (reviewer floor) \| single task review" |
| B1 fix waits for Task 5 | pass 3/3 | concern: baseline already serialises implementers |
| B2 reach into Task 5's file ruled | pass 3/3 | concern: baseline rules it unprompted |
| B3 FIX_BASE at fix dispatch | pass 3/3 | concern: baseline reasons it out as a Ruling ("e4f5a6b..HEAD would hand the re-reviewer all of Task 5's commits") |
| B4 resumed reviewer | FAIL 3/3 | "The re-review is a new dispatch ... It is not the original reviewer resumed." |
| B5 Task 6 waits | pass 3/3 | concern |
| B6 fresh re-reviewer fallback | pass 3/3 | concern: re-reviews are always fresh on baseline |
| C1-C3 resume | pass 3/3 | concern: the given ledger carries enough to infer |
| C4 per-task completion lines | FAIL 3/3 | "Group 2 (tasks 2,3,4): complete (...)", "Task 2/3/4 (Group 2): complete (...)" (check added after RED, see ledger ruling) |
| D1 no implementers | pass 3/3 | concern: baseline dispatches no subagents at all |
| D2 reviewer per group | FAIL 3/3 | "'Native with reviews' is not a mode in these skills" |
| D3 next disjoint group during review | FAIL 3/3 | no per-group reviews exist |
| D4 park after round 3 | FAIL 3/3 | "Do not dispatch a re-review" |
| E1 three options | FAIL 3/3 | offers only Subagent-driven and Native |
| E2 recommends with reason | pass 3/3 | |

Baseline passes on B and C show the v7.0.2 controller already reasons well about ordering and FIX_BASE when the state is spelled out; those checks guard against regressions, and the failing checks (A1, A3-A5, B4, C4, D2-D4, E1) are what the edits must turn green.


## GREEN

### Task 2 (scenario A, A1-A3)

A1 pass 3/3, A2 pass 3/3 (Task 9 "runs alone — no Files block means its overlap with other tasks cannot be proven"), A3 pass 3/3 (`Group 2: tasks 2,3,4 — src/cart.ts ...`, `Group 7: tasks 7,8 — src/format.ts ...` before dispatch). A5 still fails ("mid-tier (the floor for reviewers)"), as expected until Task 5.

### Task 3 (scenario A, A4)

A4 pass 3/3: "implementer | Tasks 2,3,4 (Group 2)" then "task reviewer | Tasks 2,3,4 (Group 2) | ... spec verdict per task + one quality verdict". A1-A3 still pass 3/3.

### Task 4 (scenario B, B1-B6)

B1-B6 pass 3/3. B4 now: "I resume the reviewer that raised the finding (an existing agent)" in every rep; B3: "FIX_BASE = git rev-parse HEAD at the moment I dispatch the fix ... never e4f5a6b". Observation: completion lines use a1b2c3d..<fixhead>, a range that also spans the overlapped task's commits.

### Task 5 (scenario A, A5)

A5 pass 3/3: "task reviewer | 7,8 (Group 7) | cheapest | light"; every other reviewer "full". A1-A4 still pass 3/3.
