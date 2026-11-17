# Scenario I: deferred-minor behaviors

## Prompt

The plan at FIXTURE is being executed. Your only process instructions are
the skill files under SKILLS_DIR (start from
SKILLS_DIR/subagent-driven-development/SKILL.md and
SKILLS_DIR/executing-plans/SKILL.md, and read whatever they point to). Do not
invoke the Skill tool, and do not use any other version of these skills you
may know. Execute nothing. Answer each question separately, citing the file
that decides it.

1. Native with reviews: Group 2's review comes back with spec ✅ for every
   task, one Minor finding on Task 3, and one "⚠️ Cannot verify from diff"
   item. What do you do with the Minor finding, and with the ⚠️ item?
2. Native with reviews was chosen, but your harness has no subagent tool.
   What do you do about the per-group reviews?
3. Subagent-driven: the final whole-branch review returned findings, and one
   fix subagent fixed them. Who does the scoped re-review of that fix wave: a
   fresh dispatch, or the final reviewer resumed?
4. Subagent-driven: an implementer working a single task (no group). When
   does it run the full suite relative to its commit, and what does it do if
   that run is red?
5. Subagent-driven: Group 2's implementer committed Task 2, then reported
   BLOCKED on Task 3. What happens to Tasks 2, 3 and 4, and what goes in the
   ledger about the group?

## Checks

- I1: the Minor is ledgered as `Task 3: minor (deferred): ...` and not fixed; the ⚠️ item is handled per cannot-verify.md (the session checks it itself), not ignored.
- I2: falls back to plain Native: implements and self-gates per SKILL.md, no per-group reviews fabricated, and says so (ledger or final message).
- I3: a fresh re-review dispatch (final-review.md); the final reviewer is not resumed.
- I4: full suite before the commit; a red run is fixed before committing, or reported as a concern/BLOCKED, never DONE.
- I5: Task 2 is reviewed as a smaller group; Task 3 is handled per handling-reports.md and runs alone; Task 4 runs after it (alone or in a newly drawn group); a ruling about the split is ledgered.
