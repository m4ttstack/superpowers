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

### Task 6 (scenario C, C1-C4)

C1-C4 pass 3/3. C4: "Task 2: complete (group 2, commits a1b2c3d..e4f5a6b, review clean)" plus Tasks 3 and 4, "no combined Group 2: complete line". Every rep resumes Group 2 at review over a1b2c3d..e4f5a6b and Task 5 from its existing commit. `tests/sdd-ledger-format` RED (no sample) then GREEN.

### Task 7 (scenario D, D1-D4)

D1-D4 pass 3/3: no implementer dispatches; one reviewer per group or lone task via task-reviewer-prompt.md (Group 7 light on the cheapest tier); the next disjoint unit starts during each review only once the unit before has its completion lines; Task 9 (no Files block) never overlaps; "Native-with-reviews cap is 3 rounds, not SDD's 5", then park for the final reviewer. Observation: reps expect the completion line to read "(group 2, ..., 1 parked)", which task-done's fixed line format does not write.

### Task 8 (scenario E, E1-E2)

E1-E2 pass 3/3: Subagent-driven (groups of up to three), Native with reviews, Native; each rep recommends one with a plan-specific reason.

Repo fast checks after Task 8: skill-size, sdd-ledger-format, executing-plans scripts, sdd-helper-paths (after fix 6a46fb1), shell-lint, skill-layout all pass.

## Final review fix pass

Scenarios F, G and H were written for the final review's five Important findings and run against a snapshot of the pre-fix text, then (where it failed) against the fix.

| Check | Pre-fix | Post-fix | Outcome |
|---|---|---|---|
| F1-F2 SDD overlaps Task 5 during Group 2's review, with the Ruling line (Important 3) | pass 3/3 | n/a | not reproduced; no fix |
| F3 no overlap when G lacks a Files block (Important 4) | pass 3/3 ("only because Task 9 lists no files, and that proves nothing") | pass 3/3 via Scenario H runs' reasoning | text contradiction removed anyway |
| G1-G2 resume checks live agents before re-dispatch (Important 2) | pass 3/3 | n/a | not reproduced; no fix |
| H1 Native with reviews ledgers dispatched + implemented lines (Important 1) | FAIL 2/3 ("No Group 2: dispatched ... or implemented ... line is written") | pass 3/3 | fixed |
| H2 resume at Group 2's review, no redo | pass 3/3, with caveat "nothing on executing-plans' read path points to [the group resume rule]" | pass 3/3, via the new Resuming section | fixed |
| H3 fix waits for G+1's last task (Important 5; question revised after the first pre-fix run) | FAIL 3/3 ("I start the fix after Task 3 ... before Task 4") | pass 3/3 ("finish Group 2 through Task 4's commit") | fixed |

## Deferred-minor fix pass

Scenario I covers the minors that change behavior. It ran against a snapshot of the text before this pass, then against the fix. The other minors are wording and consistency fixes, so one regression run each of A, B, C, D, F and H guards them.

| Check | Pre-fix | Post-fix |
|---|---|---|
| I1 Minor deferred, ⚠️ via cannot-verify.md (Native with reviews) | pass 3/3, borrowed from SDD files ("group-reviews.md never says") | pass 3/3, cites group-reviews step 6 |
| I2 no subagent tool: run as Native, say so | pass 3/3 by ruling ("No file decides this") | pass 3/3, cites "Without a subagent tool" |
| I3 final fix-wave re-review is a fresh dispatch | FAIL 3/3 ("The final reviewer, resumed") | pass 3/3 |
| I4 lone implementer runs the full suite before commit; red is never DONE | FAIL 3/3 ("after its commit") | pass 3/3 |
| I5 partial group: split ruled and ledgered, later tasks redrawn | FAIL 1/3 (no ruling) | pass 3/3 |

Regression runs after the pass (1 rep each): A1-A5, B1-B6, C1-C4, D1-D4, F1-F3, H1-H3 all pass. B now writes completion ranges as `a1b2c3d..e4f5a6b + <fixbase7>..<fixhead7>`.
