# Resuming From an Existing Ledger

Part of superpowers:subagent-driven-development. This plan's workspace
already has a ledger at `<workspace>/progress.md`.

If the ledger's first line names your plan file, tasks with a `Task <N>:
complete` line are DONE — do not re-dispatch them; resume at the first
task without one. A task whose last line is a fix round is mid-loop:
resume the loop at the next round.

A group (task-groups.md, Ledger lines) resumes as a unit, from its latest
`Group <G>:` line:

- `dispatched` with no `implemented`: the implementer was running. Check for
  its report file and the commits since its base; resume or re-dispatch it to
  finish from those commits, never from scratch.
- `implemented` or `review ...` with no completion lines: the work exists.
  Resume at the review (recover the verdict if the reviewer finished, or
  dispatch the review again over the recorded range), or at the next fix
  round if one is ledgered.
- When the group completes, write one `Task <N>: complete` line per member.

Under overlap two units can be in flight at once (group G in review, G+1's
implementer running). Resume each from its own lines; neither waits on the
other except for the one-implementer rule. A ledger whose first line names a
different plan file — or a stray ledger at the old flat path
`.superpowers/sdd/progress.md` — is another plan's progress: leave it in
place and start your own, fresh.
