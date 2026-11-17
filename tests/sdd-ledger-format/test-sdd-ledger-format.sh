#!/usr/bin/env bash
# Checks the sample SDD ledger against the line formats in
# skills/subagent-driven-development/references/task-groups.md: grouped
# tasks keep one `Task <N>: complete` line each, which is what ledger readers
# count, and `Group` lines never claim completion.
#
# Usage: tests/sdd-ledger-format/test-sdd-ledger-format.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LEDGER="$SCRIPT_DIR/sample-group-ledger.md"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

[ -f "$LEDGER" ] || fail "no sample ledger at $LEDGER"

done_lines=$(grep -cE '^Task[[:space:]]+[0-9]+[a-z]?:[[:space:]]*complete' "$LEDGER" || true)
[ "$done_lines" -eq 7 ] || fail "expected 7 completion lines, got $done_lines"
grep -qE '^Task 6b: complete \(group 6a, ' "$LEDGER" || fail "lettered task lost its letter"
if grep -qE '^Group[[:space:]]+[0-9]+[a-z]?:.*\bcomplete\b' "$LEDGER"; then
  fail "a Group line says complete"
fi
grep -qE '^Group 2: tasks 2,3,4 — ' "$LEDGER" || fail "group drawn line missing"
grep -qE '^Group 2: dispatched, base [0-9a-f]{7}$' "$LEDGER" || fail "group dispatched line missing"
grep -qE '^Group 2: implemented [0-9a-f]{7}\.\.[0-9a-f]{7}$' "$LEDGER" || fail "group implemented line missing"
grep -qE '^Group 2: review (light|full) \(reviewer [^)]+\)$' "$LEDGER" || fail "group review line missing depth or reviewer id"
grep -qE '^Ruling: Group 6a dispatched during Task 5.s review — files disjoint — ' "$LEDGER" || fail "overlap dispatch of Group 6a has no ruling"
grep -qE '^Group 2: fix round 1/5 \(' "$LEDGER" || fail "group fix round line missing"

echo "PASS: sample ledger matches the group line formats"
