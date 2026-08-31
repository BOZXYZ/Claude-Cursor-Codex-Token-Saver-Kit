#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${REPO_ROOT}/scripts/lib.sh"

AGENT="${1:-cursor}"

log() { printf 'ccctsk: %s\n' "$*"; }

case "$AGENT" in
  cursor)
    rm -f "${HOME}/.cursor/hooks/rtk-rewrite.sh"
    rm -f "${HOME}/.cursor/hooks/to-"*.sh
  rm -f "${HOME}/.cursor/rules/caveman.mdc" "${HOME}/.cursor/rules/token-efficiency.mdc"
    if [ -f "${HOME}/.cursor/hooks.json" ]; then
      log "hooks.json not removed — edit manually if you installed ccctsk hooks"
    fi
    if command -v rtk >/dev/null 2>&1; then
      rtk init -g --agent cursor --uninstall 2>/dev/null || true
    fi
    ;;
  claude)
    if command -v rtk >/dev/null 2>&1; then
      rtk init -g --uninstall 2>/dev/null || true
    fi
    ;;
  codex)
    log "Remove Codex RTK.md / AGENTS.md references manually if added"
    ;;
  *)
    log "Usage: ./uninstall.sh [cursor|claude|codex]"
    exit 1
    ;;
esac

log "Uninstalled ccctsk hooks for $AGENT (plugins/skills not removed)"
