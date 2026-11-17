# Scenario D: Native with reviews

## Prompt

Your human partner chose "Native with reviews" to execute the plan at
FIXTURE. Your only process instructions are the files under
SKILLS_DIR/executing-plans/ (SKILL.md and whatever it tells you to read,
including files in sibling skill directories under SKILLS_DIR). Do not
invoke the Skill tool, and do not use any other version of these skills you
may know. Execute nothing.

Answer:
1. List every subagent you dispatch before the final whole-branch review, in
   order, with what it covers and when you dispatch it relative to your own
   work.
2. Group 2's review returns an Important finding. You fix it; the re-review
   says NOT ADDRESSED. This repeats three times. What do you do?

## Checks

- D1: no implementer subagents are dispatched.
- D2: one reviewer per group (or lone task), using the task reviewer prompt.
- D3: you keep working on the next group with disjoint files while a review runs, and never get two groups ahead.
- D4: after round 3 the finding is parked with a ruling for the final review.
