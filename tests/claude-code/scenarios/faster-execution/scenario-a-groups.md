# Scenario A: drawing groups

## Prompt

You are the controller session about to execute the plan at FIXTURE with
subagent-driven-development. Your only process instructions are the files
under SKILLS_DIR/subagent-driven-development/ (SKILL.md and whatever it tells
you to read). Do not invoke the Skill tool, and do not use any other version
of these skills you may know. Execute nothing: no dispatches, no git, no file
writes. Assume every implementer reports DONE with green tests and every
review comes back clean.

Answer in exactly this format:

LEDGER BEFORE TASK 1:
<every ledger line you would write before the first implementer dispatch, verbatim>

DISPATCHES:
<one line per subagent you would dispatch before the final whole-branch review, in order: role | tasks covered | model tier | review depth if a reviewer>

## Checks

- A1: tasks are grouped as {1}, {2,3,4}, {5}, {6}, {7,8}, {9}: one implementer covers tasks 2-4, one covers 7-8.
- A2: Task 6 and Task 9 each run alone (9 has no Files block).
- A3: a `Group 2: tasks 2,3,4 — ...` ledger line appears before the first dispatch.
- A4: Group 2 gets exactly one implementer and one reviewer.
- A5: the reviewer for tasks 7-8 is a light review on the cheapest tier.
