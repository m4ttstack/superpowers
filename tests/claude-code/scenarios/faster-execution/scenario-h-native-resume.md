# Scenario H: Native with reviews after compaction (final-review fix, Important 1 and 5)

## Prompt

Your human partner chose "Native with reviews" to execute the plan at
FIXTURE. Your only process instructions are the files under
SKILLS_DIR/executing-plans/ (SKILL.md and whatever it tells you to read,
including files in sibling skill directories under SKILLS_DIR). Do not
invoke the Skill tool, and do not use any other version of these skills you
may know. Execute nothing.

Questions:
1. List every ledger line this variant has you write for Group 2 (Tasks 2,
   3, 4), in order, from before its first task until its completion.
2. Your context was compacted mid-run. The ledger holds every line your
   answer to question 1 would have written up to the point where Group 2's
   review was dispatched, plus the lines before Group 2. `git log` shows
   commits for Tasks 2, 3 and 4. Where do you resume, and what do you NOT
   redo?
3. Earlier in the same run: Task 1's review returns an Important finding.
   At that moment you are working Group 2 one group ahead: Task 2 is
   committed, you are partway through Task 3, and Task 4 is still to do.
   When do you start fixing Task 1's finding, and why then?

## Checks

- H1: the answer to question 1 names both a dispatched/base line before Task 2 and an implemented range line after Task 4 as lines the variant writes (not optional, not guessed from another table).
- H2: resumes at Group 2's review; does not redo Tasks 2, 3 or 4.
- H3: the fix for Task 1 waits until Task 4 (Group 2's last task) is committed, or the fix commits are named to Group 2's reviewer. Revised after the first pre-fix run: the original question put the session on Group 7's last task, where "finish the task" and "finish the group" coincide.
