#!/usr/bin/env bash
# Shared Token Optimizer bridge for Cursor hooks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/lib.sh" ]; then
  # shellcheck source=lib.sh
  source "${SCRIPT_DIR}/lib.sh"
elif [ -f "${SCRIPT_DIR}/../scripts/lib.sh" ]; then
  # shellcheck source=../scripts/lib.sh
  source "${SCRIPT_DIR}/../scripts/lib.sh"
fi

export TOKEN_OPTIMIZER_CURSOR=1
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(resolve_token_optimizer_root || true)}"

if [ -z "${CLAUDE_PLUGIN_ROOT:-}" ] || [ ! -d "$CLAUDE_PLUGIN_ROOT" ]; then
  echo "[ccctsk/token-optimizer] plugin not installed — skip hooks" >&2
  echo "[ccctsk/token-optimizer] install: claude plugin marketplace add alexgreensh/token-optimizer && claude plugin install token-optimizer@alexgreensh-token-optimizer" >&2
  exit 0
fi

LAUNCHER="$CLAUDE_PLUGIN_ROOT/hooks/python-launcher.sh"
RUNNER="$CLAUDE_PLUGIN_ROOT/hooks/run.py"

if [ ! -f "$LAUNCHER" ]; then
  echo "[ccctsk/token-optimizer] launcher missing at $LAUNCHER" >&2
  exit 0
fi

exec bash "$LAUNCHER" "$RUNNER" "$@"
