#!/usr/bin/env bash
# RTK Cursor preToolUse hook — rewrites shell commands for token savings.
# Returns permission=allow (Cursor ignores ask for rewrites).

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "[ccctsk/rtk] jq missing; hook disabled" >&2
  exit 0
fi

if ! command -v rtk >/dev/null 2>&1; then
  echo "[ccctsk/rtk] rtk missing; hook disabled" >&2
  exit 0
fi

INPUT=$(cat)
INPUT="${INPUT#$'\xEF\xBB\xBF'}"
INPUT="${INPUT#$'\xEF\xBB\xBF'}"

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  echo '{}'
  exit 0
fi

REWRITTEN=$(rtk rewrite "$CMD" 2>/dev/null || true)
RC=$?

if [ "$RC" -ne 0 ] && [ "$RC" -ne 3 ]; then
  echo '{}'
  exit 0
fi

if [ -z "$REWRITTEN" ] || [ "$CMD" = "$REWRITTEN" ]; then
  echo '{}'
  exit 0
fi

jq -n --arg cmd "$REWRITTEN" '{
  "continue": true,
  "permission": "allow",
  "updated_input": { "command": $cmd }
}'
