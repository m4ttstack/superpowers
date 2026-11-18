# Superpowers (mattstack fork)

A fork of [obra/superpowers](https://github.com/obra/superpowers) 7.0.2 that runs implementation plans faster. Every other skill is upstream's, unchanged.

## What's different

- **Task groups.** Subagent-driven development groups related tasks (up to three) before it starts. One implementer builds a group and one reviewer checks it, instead of one of each per task.
- **Lighter reviews where they fit.** A group that only transcribes the plan gets a light review. The next group starts while the current one is in review, and a re-review goes back to the same reviewer.
- **Native with reviews.** A new way to run `executing-plans`: you implement every task in your own session, and a fresh reviewer checks each group before you move on. One whole-branch review runs at the end.
- **Three choices at handoff.** `writing-plans` offers Subagent-driven, Native with reviews, or Native.
- **Resumable groups.** The ledger records each group, so a run picks up where it left off after compaction.

## Installation

mattstack installs this fork for you. To install it by hand for Claude Code:

```bash
claude plugin marketplace add m4ttstack/superpowers
claude plugin install superpowers@superpowers-dev
```

Versions read `<upstream version>-groups.<n>`, for example `7.0.2-groups.1`.

## Usage

Nothing new to learn. When `writing-plans` finishes a plan, it asks how to run it: Subagent-driven, Native with reviews, or Native. Pick one and the matching skill takes over.

## Everything else

For the workflow, the other harnesses and the full skill list, read the upstream README:

- [Upstream README at 7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/README.md), the version this fork is built on
- [Latest upstream README](https://github.com/obra/superpowers#readme)

## License

MIT, same as upstream. See [LICENSE](LICENSE).
