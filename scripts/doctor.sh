#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${REPO_ROOT}/scripts/lib.sh"

ok=0
warn=0
fail=0

check() {
  local label="$1" status="$2" detail="${3:-}"
  case "$status" in
    ok)   printf '  [OK]  %s' "$label"; ok=$((ok + 1)) ;;
    warn) printf '  [!!]  %s' "$label"; warn=$((warn + 1)) ;;
    *)    printf '  [XX]  %s' "$label"; fail=$((fail + 1)) ;;
  esac
  [ -n "$detail" ] && printf ' — %s' "$detail"
  printf '\n'
}

echo "claude-cursor-codex-token-saver-kit doctor"
echo "=========================================="

if command -v rtk >/dev/null 2>&1; then
  check "RTK" ok "$(rtk --version 2>/dev/null | head -1)"
  savings="$(rtk gain 2>/dev/null | grep 'Tokens saved' | head -1 || true)"
  [ -n "$savings" ] && check "RTK savings" ok "$savings"
else
  check "RTK" fail "not on PATH"
fi

if command -v jq >/dev/null 2>&1; then
  check "jq" ok
else
  check "jq" warn "required for Cursor RTK hook"
fi

if [ -f "${HOME}/.cursor/hooks/rtk-rewrite.sh" ]; then
  check "Cursor RTK hook" ok "~/.cursor/hooks/rtk-rewrite.sh"
else
  check "Cursor RTK hook" warn "run ./install.sh --agent cursor"
fi

if [ -f "${HOME}/.cursor/hooks.json" ]; then
  check "Cursor hooks.json" ok
else
  check "Cursor hooks.json" warn "missing"
fi

to_root="$(resolve_token_optimizer_root 2>/dev/null || true)"
if [ -n "$to_root" ]; then
  check "Token Optimizer plugin" ok "$to_root"
  if [ -f "${to_root}/skills/token-optimizer/scripts/measure.py" ]; then
    python3 "${to_root}/skills/token-optimizer/scripts/measure.py" doctor 2>/dev/null | tail -3 || true
  fi
else
  check "Token Optimizer plugin" warn "install via Claude Code marketplace"
fi

if [ -d "${HOME}/.cursor/skills" ] || [ -d "${HOME}/.agents/skills/caveman" ]; then
  check "Caveman skills" ok
else
  check "Caveman skills" warn "npx skills add JuliusBrussee/caveman -a cursor"
fi

if curl -sS -o /dev/null -w '' http://127.0.0.1:24842/token-optimizer 2>/dev/null; then
  check "TO dashboard" ok "http://localhost:24842/token-optimizer"
else
  check "TO dashboard" warn "run measure.py setup-daemon"
fi

echo
echo "Summary: ${ok} ok, ${warn} warnings, ${fail} failures"

if [ -f "${HOME}/.cursor/hooks/rtk-rewrite.sh" ]; then
  echo
  echo "RTK hook test:"
  echo '{"tool_name":"Shell","tool_input":{"command":"git status"}}' | "${HOME}/.cursor/hooks/rtk-rewrite.sh"
fi
