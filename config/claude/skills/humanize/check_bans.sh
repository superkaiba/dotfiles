#!/usr/bin/env bash
# Hard gate for the humanize skill.
#
# Usage: check_bans.sh <file>
#
# Exits 0 with "PASS: ..." line if no absolute-ban terms are found in <file>.
# Exits 1 with "FAIL: ..." and the matching lines if any absolute-ban term is
# present. Watch-list hits are reported on PASS but do not fail the gate.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <file>" >&2
  exit 2
fi

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ABSOLUTE="$SCRIPT_DIR/banned_absolute.txt"
WATCH="$SCRIPT_DIR/banned_watch.txt"

if [ ! -f "$TARGET" ]; then
  echo "check_bans.sh: target file not found: $TARGET" >&2
  exit 2
fi
if [ ! -f "$ABSOLUTE" ]; then
  echo "check_bans.sh: ban list missing: $ABSOLUTE" >&2
  exit 2
fi

abs_hits=$(grep -niEf "$ABSOLUTE" "$TARGET" 2>/dev/null || true)
if [ -n "$abs_hits" ]; then
  echo "FAIL: absolute-ban terms found in $TARGET:"
  echo "$abs_hits"
  exit 1
fi

if [ -f "$WATCH" ]; then
  watch_hits=$(grep -niEf "$WATCH" "$TARGET" 2>/dev/null || true)
  if [ -n "$watch_hits" ]; then
    watch_count=$(printf '%s\n' "$watch_hits" | wc -l | tr -d ' ')
    echo "PASS (absolute bans clean) — $watch_count watch-list match(es) found:"
    echo "$watch_hits"
    echo "---"
    echo "Watch-list hits don't fail the gate. Review for clustering (>= 2 in same paragraph = rewrite)."
    exit 0
  fi
fi

echo "PASS: no banned or watch-list terms found in $TARGET"
exit 0
