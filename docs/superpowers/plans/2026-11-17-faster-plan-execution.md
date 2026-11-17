# Faster Plan Execution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cut agent cold starts in plan execution: task groups, one-ahead overlap, resumed reviewers, review depth by risk and targeted tests in SDD, plus a "Native with reviews" mode in executing-plans.

**Architecture:** All changes are skill text (markdown) in `skills/subagent-driven-development/`, `skills/executing-plans/` and `skills/writing-plans/`. New rules live in two new reference files so the `SKILL.md` files stay under the size cap. Every edit is proven per superpowers:writing-skills: a scenario run against the v7.0.2 text (RED), the edit, the same scenario against the edited text (GREEN).

**Tech Stack:** Markdown skills, bash test scripts under `tests/`, Agent-tool subagents for scenario runs.

**Spec:** `docs/superpowers/specs/2026-11-17-sdd-task-groups-design.md`

## Global Constraints

- Every `skills/*/SKILL.md` stays under 20,000 bytes (`tests/skill-size/test-skill-size.sh`).
- Every task in a group still gets its own ledger line matching `^Task\s+(\d+)([a-z]?):\s*complete`.
- Group-scoped ledger lines start `Group <G>:`, where `<G>` is the group's first task number (my call: ties the group to its tasks, needs no new counter). A task running alone writes no `Group` lines.
- Group cap: 3 consecutive tasks. A task needing the most capable tier always runs alone.
- One group ahead, no further. At most one implementer active at a time.
- FIX_BASE for a fix round is `HEAD` when the fix is dispatched.
- Light review: cheapest tier, per-task spec verdicts and Critical findings only.
- Native with reviews: fix loop capped at 3 rounds; residual findings parked for the final review.
- New files: `skills/subagent-driven-development/references/task-groups.md`, `skills/executing-plans/references/group-reviews.md`.
- Mode name, verbatim: `Native with reviews`.
- Scenario fixtures live under `tests/claude-code/scenarios/faster-execution/`.

## Review Focus

1. A plan task with no `**Files:**` block or vague paths: it cannot be proven disjoint or shared, so it runs alone and never overlaps. Pinned in Task 2's scenario.
2. Lettered task ids (`Task 6b`) inside a group: completion lines must keep the letter (`Task 6b: complete`). Pinned in Task 6's ledger test.
3. A fix round on group G whose fix touches a file group G+1 owns: the fix waits for G+1's implementer, and the conflict is ruled and ledgered. Pinned in Task 4's scenario.
4. A harness that cannot message a live subagent: re-reviews fall back to a fresh re-reviewer. Pinned in Task 4's scenario.
5. Compaction while G is in review and G+1's implementer is running: resume handles both without re-dispatching either. Pinned in Task 6's scenario.

## How scenario runs work (every task uses this)

- **Baseline tree:** Task 1 extracts the v7.0.2 skills to `<workspace>/baseline/skills/` with `git archive v7.0.2 skills | tar -x -C <workspace>/baseline`.
- **A run:** dispatch one fresh subagent (`model: opus`, `effort: medium`) with the scenario file's prompt, `SKILLS_DIR` replaced by either the baseline path (RED) or this checkout's `skills/` (GREEN). The prompt tells it to read only the named skill files and the fixture plan, execute nothing, and answer in the scenario's output format.
- **Reps:** 3 per variant. Read every output yourself; a check passes only when all 3 reps pass it.
- **Who runs them:** the session executing the plan. Under subagent-driven execution that is the controller, before the task review, because implementers never dispatch subagents.
- **Record:** append each run's verdict per check to `tests/claude-code/scenarios/faster-execution/RESULTS.md` under the scenario's heading, with one verbatim quote per failing check.

---

### Task 1: Scenario fixtures and RED baseline

**Files:**
- Create: `tests/claude-code/scenarios/faster-execution/fixture-plan.md`
- Create: `tests/claude-code/scenarios/faster-execution/scenario-a-groups.md`
- Create: `tests/claude-code/scenarios/faster-execution/scenario-b-overlap-fix.md`
- Create: `tests/claude-code/scenarios/faster-execution/scenario-c-resume.md`
- Create: `tests/claude-code/scenarios/faster-execution/scenario-d-native-reviews.md`
- Create: `tests/claude-code/scenarios/faster-execution/scenario-e-handoff.md`
- Create: `tests/claude-code/scenarios/faster-execution/RESULTS.md`

**Interfaces:**
- Produces: the five scenario files and the fixture plan every later task runs; the baseline tree at `<workspace>/baseline/skills/`.

- [ ] **Step 1: Write the fixture plan**

A writing-plans-shaped plan (header, Global Constraints, 9 tasks with `**Files:**` and `**Interfaces:**` blocks; step bodies may be one line each except where noted):

| Task | Files | Notes |
|---|---|---|
| 1 | `src/config.ts` | produces `loadConfig()`, consumed only by Task 9 |
| 2 | `src/cart.ts` | produces `Money`, `addItem` |
| 3 | `src/cart.ts` | `removeItem` |
| 4 | `src/cart.ts` | `cartTotal(): Money` |
| 5 | `src/discounts.ts` | consumes `cartTotal` |
| 6 | `src/checkout.ts` | text says it needs design judgment across cart, discounts and payment (most capable tier) |
| 7 | `src/format.ts` | complete code in every code step |
| 8 | `src/format.ts` | complete code in every code step |
| 9 | `src/cli.ts` | consumes `loadConfig()`; has **no** `**Files:**` block (Review Focus 1) |

Expected grouping under the new rules: `{1}`, `Group 2 = {2,3,4}`, `{5}`, `{6}`, `Group 7 = {7,8}` (transcription), `{9}`.

- [ ] **Step 2: Write the five scenario files**

Each holds a prompt with `SKILLS_DIR` and `FIXTURE` placeholders, an output format, and numbered checks:

- **A, groups:** "You are the controller about to execute FIXTURE with subagent-driven-development (SKILLS_DIR/subagent-driven-development). List, in order, every subagent you would dispatch before the final review (role, tasks covered, model tier), and every ledger line you would write before Task 1's dispatch." Checks: A1 groups match the expected grouping; A2 Task 6 and Task 9 run alone; A3 a `Group 2: tasks 2,3,4 — ...` line before any dispatch; A4 one implementer and one reviewer for Group 2; A5 Group 7's review is light on the cheapest tier.
- **B, overlap and fix:** state: Group 2 implemented (`a1b2c3d..e4f5a6b`), its review returned one Important finding on Task 3 that touches `src/discounts.ts` as well as `src/cart.ts`; Task 5's implementer is running. Ask: what happens next, in order, with ledger lines. Checks: B1 the fix waits until Task 5's implementer reports; B2 the finding's reach into Task 5's file is ruled and ledgered (Review Focus 3); B3 FIX_BASE is `HEAD` at fix dispatch; B4 the re-review resumes the reviewer that raised the finding; B5 Task 6 is not dispatched until Tasks 2-4 all have completion lines; B6 if the harness cannot resume a subagent, a fresh re-reviewer (Review Focus 4).
- **C, resume:** a ledger after compaction with `Group 2: dispatched, base a1b2c3d`, `Group 2: implemented a1b2c3d..e4f5a6b`, `Group 2: review full`, `Task 5: ...dispatched` and no completion lines. Ask: where do you resume, and what do you not re-dispatch? Checks: C1 Group 2's implementer is not re-dispatched; C2 Group 2 resumes at its review; C3 Task 5 resumes from its report file and commits since its base (Review Focus 5).
- **D, native with reviews:** "Execute FIXTURE with executing-plans (SKILLS_DIR/executing-plans) in its Native with reviews variant. List every subagent you dispatch and when, and what you do when a review returns an Important finding three rounds running." Checks: D1 no implementer subagents; D2 one reviewer per group, using `task-reviewer-prompt.md`; D3 work on the next disjoint group continues while a review runs, never two groups ahead; D4 after round 3 the finding is parked with a ruling for the final review.
- **E, handoff:** "You just finished writing FIXTURE with writing-plans (SKILLS_DIR/writing-plans). Write your handoff message." Checks: E1 offers three options including `Native with reviews`; E2 recommends one with a reason.

- [ ] **Step 3: Extract the baseline and run RED**

Run: `git archive v7.0.2 skills | tar -x -C <workspace>/baseline`
Then run scenarios A-E against the baseline, 3 reps each.
Expected: A1, A3, A5, B3, B4, C1-C3 (group lines), D1-D4 (variant missing) and E1 fail. Record verbatim in `RESULTS.md` under "RED". A check that already passes on baseline is reported as a concern, with its quote.

- [ ] **Step 4: Commit**

```bash
git add tests/claude-code/scenarios/faster-execution
git commit -m "test: scenario fixtures and RED baseline for faster plan execution"
```

### Task 2: Drawing groups at pre-flight

**Files:**
- Create: `skills/subagent-driven-development/references/task-groups.md`
- Modify: `skills/subagent-driven-development/references/preflight.md`
- Modify: `skills/subagent-driven-development/SKILL.md` (pointer; trims to fit)

**Interfaces:**
- Consumes: Task 1's scenario A.
- Produces: `references/task-groups.md` with a section `## Drawing groups`, which Tasks 3-6 extend with `## Running a group`, `## Overlap`, `## Ledger lines`, `## Partial outcomes`.

- [ ] **Step 1: Confirm scenario A's RED is recorded** (A1-A3 failing in `RESULTS.md`).
- [ ] **Step 2: Write `## Drawing groups` in `task-groups.md`** per the spec's "Drawing groups (pre-flight)": consecutive tasks, shared file or produced/consumed interface, cap 3, most-capable-tier tasks alone, a task with no `**Files:**` block alone (Review Focus 1), the `Group <G>: tasks ... — <shared file or interface>` line before Task 1's dispatch.
- [ ] **Step 3: `preflight.md`** gains one paragraph: after the table, draw groups per `task-groups.md`, using the table's shared-file and shared-interface rows.
- [ ] **Step 4: `SKILL.md`** gets a pointer in Setup and in The Task Loop to `references/task-groups.md`. Trim existing text so the file stays under 20,000 bytes.
- [ ] **Step 5: Verify size**

Run: `tests/skill-size/test-skill-size.sh`
Expected: `PASS: every SKILL.md is under 20000 bytes`

- [ ] **Step 6: GREEN on scenario A, checks A1-A3** (3 reps against `skills/`). Expected: all pass. Record under "GREEN".
- [ ] **Step 7: Commit** `sdd: draw task groups at pre-flight`

### Task 3: Running a group

**Files:**
- Modify: `skills/subagent-driven-development/references/task-groups.md` (add `## Running a group`, `## Partial outcomes`)
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `skills/subagent-driven-development/references/handling-reports.md`
- Modify: `skills/subagent-driven-development/references/batching.md`
- Modify: `skills/subagent-driven-development/SKILL.md` (completion line format, process graph label)

**Interfaces:**
- Consumes: `task-groups.md` from Task 2.
- Produces: implementer template placeholders `[BRIEF_FILES]` (ordered list) and report sections `## Task <N>`; reviewer template returns `Spec (Task <N>): ✅|❌` per task plus one quality verdict.

- [ ] **Step 1: `## Running a group`** per the spec's "Running a group": one `task-brief` run per member task, every brief path in order, one implementer, one commit per task minimum, one report with a section per task, highest member tier, one review over BASE..HEAD, per-task spec verdicts, per-task completion lines `Task <N>: complete (group <G>, commits <a7>..<b7>, review clean)` written together, parked counts on the named task's line.
- [ ] **Step 2: Targeted tests in `implementer-prompt.md`:** replace "run the full suite once before committing, not after every edit" with: covering tests before each task's commit; the full suite once after the last task's commit, before the report.
- [ ] **Step 3: Multiple briefs** in `implementer-prompt.md` and `task-reviewer-prompt.md` (`[BRIEF_FILES]`, per-task sections, per-task spec verdicts).
- [ ] **Step 4: `## Partial outcomes`** per the spec, and its sentence in `handling-reports.md`.
- [ ] **Step 5: `batching.md`:** one line distinguishing batching from groups; batched tasks get per-task completion lines.
- [ ] **Step 6: Verify size** (`tests/skill-size/test-skill-size.sh`, PASS).
- [ ] **Step 7: GREEN on scenario A, check A4.** Expected: pass in all reps.
- [ ] **Step 8: Commit** `sdd: run a group with one implementer and one review`

### Task 4: Overlap and resumed reviewers

**Files:**
- Modify: `skills/subagent-driven-development/references/task-groups.md` (add `## Overlap`)
- Modify: `skills/subagent-driven-development/references/fix-loop.md`
- Modify: `skills/subagent-driven-development/re-review-prompt.md`
- Modify: `skills/subagent-driven-development/SKILL.md` (record reviewer identity; "never dispatch multiple implementation subagents in parallel" stays)

**Interfaces:**
- Consumes: `## Running a group` from Task 3.
- Produces: reviewer agent identity recorded at dispatch; re-review prompt usable as a follow-up message.

- [ ] **Step 1: `## Overlap`** per the spec's "Overlap": disjoint planned files, the `Ruling: G+1 dispatched during G's review — files disjoint — cost if wrong: rework of G+1` line, one group ahead, one implementer at a time, G's fix waits for G+1's implementer, a fix reaching into G+1's files is ruled and ledgered (Review Focus 3).
- [ ] **Step 2: `fix-loop.md`:** group as the unit with findings naming their task; `Group <G>: fix round <R>/5 (...)` for groups; FIX_BASE = `HEAD` at fix dispatch; re-reviews resume the reviewer that raised the findings, rounds 4-5 included; fresh re-reviewer when the harness cannot message a live subagent (Review Focus 4).
- [ ] **Step 3: `re-review-prompt.md`:** a short lead saying how to send it to a resumed reviewer (the prompt body as a message, no dispatch header); the "Fix base" line reads "HEAD when the fix was dispatched".
- [ ] **Step 4: Verify size** (PASS).
- [ ] **Step 5: GREEN on scenario B, checks B1-B6.** Expected: pass in all reps.
- [ ] **Step 6: Commit** `sdd: overlap one group ahead and resume reviewers for re-reviews`

### Task 5: Review depth by risk

**Files:**
- Modify: `skills/subagent-driven-development/references/task-groups.md` (light review under `## Running a group`)
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md` (light variant)
- Modify: `skills/subagent-driven-development/SKILL.md` (Model Selection exception)

**Interfaces:**
- Consumes: reviewer template from Task 3.
- Produces: ledger lines `Group <G>: review light|full` and `Task <N>: review light|full`; a `[REVIEW_DEPTH]` switch in the reviewer template.

- [ ] **Step 1: Light review rules** per the spec's "Review depth by risk": the transcription test, cheapest tier, per-task spec verdicts and Critical only, findings enter the fix loop as usual, everything else full.
- [ ] **Step 2: Reviewer template light variant** keyed on `[REVIEW_DEPTH]` = `light`: skip the quality rubric except Critical.
- [ ] **Step 3: Model Selection:** one sentence: a light review is one package read and a verdict, so the mid-tier reviewer floor does not apply.
- [ ] **Step 4: Verify size** (PASS).
- [ ] **Step 5: GREEN on scenario A, check A5.** Expected: pass in all reps.
- [ ] **Step 6: Commit** `sdd: light review for transcription groups`

### Task 6: Ledger lines and resuming

**Files:**
- Modify: `skills/subagent-driven-development/references/task-groups.md` (add `## Ledger lines`)
- Modify: `skills/subagent-driven-development/references/resuming.md`
- Create: `tests/sdd-ledger-format/test-sdd-ledger-format.sh`
- Create: `tests/sdd-ledger-format/sample-group-ledger.md`

**Interfaces:**
- Consumes: every `Group` line introduced by Tasks 2-5.
- Produces: the complete ledger line list in `## Ledger lines`.

- [ ] **Step 1: Write the failing ledger test**

`sample-group-ledger.md` holds a ledger with groups `2 = {2,3,4}` and `6 = {6a,6b}`, every `Group` line, and completion lines for all six tasks. `test-sdd-ledger-format.sh` asserts:

```bash
done=$(grep -cE '^Task[[:space:]]+[0-9]+[a-z]?:[[:space:]]*complete' "$LEDGER")
[ "$done" -eq 6 ] || fail "expected 6 completion lines, got $done"
grep -qE '^Task 6b: complete \(group 6, ' "$LEDGER" || fail "lettered task lost its letter"
! grep -qE '^Group[[:space:]]+[0-9]+:.*\bcomplete\b' "$LEDGER" || fail "a Group line says complete"
grep -qE '^Group 2: tasks 2,3,4 — ' "$LEDGER" || fail "group drawn line missing"
```

- [ ] **Step 2: Run it before the sample exists**

Run: `bash tests/sdd-ledger-format/test-sdd-ledger-format.sh`
Expected: FAIL (no sample ledger).

- [ ] **Step 3: Write `## Ledger lines`** listing every line from the spec's "Ledger lines (my call)", then write the sample ledger from that list.
- [ ] **Step 4: Run the test** — Expected: PASS.
- [ ] **Step 5: `resuming.md`** per the spec: `dispatched` without `implemented` resumes the implementer from its report and commits since base; `implemented` without completion lines resumes at review or the next fix round; G and G+1 both in flight resume both (Review Focus 5).
- [ ] **Step 6: GREEN on scenario C, checks C1-C3.** Expected: pass in all reps.
- [ ] **Step 7: Commit** `sdd: group ledger lines and resuming`

### Task 7: Native with reviews

**Files:**
- Create: `skills/executing-plans/references/group-reviews.md`
- Modify: `skills/executing-plans/SKILL.md` (pointer in When to Use and The Task Loop)

**Interfaces:**
- Consumes: `../subagent-driven-development/references/task-groups.md` (drawing groups, ledger lines), `../subagent-driven-development/task-reviewer-prompt.md` (light and full), `re-review-prompt.md`.
- Produces: the `Native with reviews` variant that Task 8's handoff names.

- [ ] **Step 1: `group-reviews.md`** per the spec's Phase 2 "Decided": groups drawn as SDD draws them, a short per-group report file, reviewer dispatch with briefs, report and package, review depth by risk, one group ahead, the session fixes, resumed reviewer re-reviews, 3-round cap, residuals parked with a ruling for the final review, ledger lines shared with SDD.
- [ ] **Step 2: `SKILL.md` pointer:** when your human partner chose Native with reviews, read `references/group-reviews.md` before Task 1.
- [ ] **Step 3: Verify size** (PASS).
- [ ] **Step 4: GREEN on scenario D, checks D1-D4.** Expected: pass in all reps.
- [ ] **Step 5: Commit** `executing-plans: Native with reviews variant`

### Task 8: Handoff offers three modes

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (Execution Handoff, header line)

**Interfaces:**
- Consumes: the mode name from Task 7.

- [ ] **Step 1: Execution Handoff** lists three options: Subagent-driven (wording mentions groups of related tasks), `Native with reviews` with the spec's draft wording, and Native. "If Native with reviews chosen: REQUIRED SUB-SKILL: Use superpowers:executing-plans, Native with reviews variant."
- [ ] **Step 2: Plan header line** names all three.
- [ ] **Step 3: Verify size** (PASS).
- [ ] **Step 4: GREEN on scenario E, checks E1-E2.** Expected: pass in all reps.
- [ ] **Step 5: Run the repo's fast checks**

Run: `tests/skill-size/test-skill-size.sh && bash tests/sdd-ledger-format/test-sdd-ledger-format.sh && bash tests/claude-code/test-executing-plans-scripts.sh && bash tests/sdd-helper-paths/test-sdd-helper-paths.sh`
Expected: every script exits 0.

- [ ] **Step 6: Commit** `writing-plans: offer Native with reviews at handoff`

---

## Hand-off after the final review (not tasks)

Run by the session after execution, asking Matt before each external step (spec "Shipping"):

1. Create the public fork `m4ttstack/superpowers`.
2. `scripts/bump-version.sh 7.0.2-groups.1`, commit.
3. Push branch `sdd-task-groups` and tag `v7.0.2-groups.1` to the fork.
4. Re-point `~/.claude/local-marketplaces/superpowers-pinned/.claude-plugin/marketplace.json` at the fork and tag; `/reload-plugins`.
5. Update `~/.claude/rules/subagent-execution-default.md` to default to Native with reviews.
