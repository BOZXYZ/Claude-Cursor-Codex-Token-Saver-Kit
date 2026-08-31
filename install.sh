#!/usr/bin/env bash
# claude-cursor-codex-token-saver-kit installer
# Wires RTK + Token Optimizer + Caveman for AI coding agents.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "${REPO_ROOT}/scripts/lib.sh"

AGENTS=()
DRY_RUN=0
SKIP_RTK=0
SKIP_CAVEMAN=0
SKIP_RULES=0

usage() {
  cat <<'EOF'
claude-cursor-codex-token-saver-kit installer

Usage:
  ./install.sh --agent cursor
  ./install.sh --agent claude --agent codex
  ./install.sh --all
  ./install.sh --agent cursor --dry-run

Flags:
  --agent <name>   cursor | claude | codex | copilot  (repeatable)
  --all            Install for cursor + claude + codex
  --dry-run        Print actions only
  --skip-rtk       Skip RTK install
  --skip-caveman   Skip Caveman skills/plugin
  --skip-rules     Skip Cursor rules copy
  -h, --help       Show help

Prerequisites (installed by you or this script):
  - jq, bash, python3
  - RTK (https://github.com/rtk-ai/rtk) — auto-installed on Linux unless --skip-rtk
  - Token Optimizer (Claude Code plugin) — required for Cursor hook bridge
  - Caveman (https://github.com/JuliusBrussee/caveman) — optional but recommended

EOF
}

log() { printf 'ccctsk: %s\n' "$*"; }
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

install_rtk_linux() {
  if command -v rtk >/dev/null 2>&1; then
    log "RTK already installed: $(rtk --version 2>/dev/null || echo unknown)"
    return 0
  fi
  log "Installing RTK from GitHub releases..."
  local arch url tmp
  arch="$(uname -m)"
  case "$arch" in
    x86_64) url="https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-unknown-linux-musl.tar.gz" ;;
    aarch64|arm64) url="https://github.com/rtk-ai/rtk/releases/latest/download/rtk-aarch64-unknown-linux-gnu.tar.gz" ;;
    *) log "Unsupported arch for auto RTK install: $arch — install manually"; return 1 ;;
  esac
  tmp="$(mktemp -d)"
  run curl -fsSL "$url" -o "$tmp/rtk.tar.gz"
  run tar -xzf "$tmp/rtk.tar.gz" -C "$tmp"
  run mkdir -p "${HOME}/.local/bin"
  run install -m 755 "$tmp/rtk" "${HOME}/.local/bin/rtk"
  log "RTK installed to ~/.local/bin/rtk (ensure it is on PATH)"
}

install_caveman_agent() {
  local agent="$1"
  case "$agent" in
    cursor)
      run npx -y skills add JuliusBrussee/caveman -a cursor -g
      ;;
    codex)
      run npx -y skills add JuliusBrussee/caveman -a codex -g
      ;;
    copilot)
      run npx -y github:JuliusBrussee/caveman -- --only copilot --with-init
      ;;
    claude)
      if command -v claude >/dev/null 2>&1; then
        run claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
        run claude plugin install caveman@caveman 2>/dev/null || log "caveman plugin may already be installed"
      else
        log "claude CLI not found — install Claude Code, then: claude plugin install caveman@caveman"
      fi
      ;;
  esac
}

install_token_optimizer_hint() {
  log "Token Optimizer (required for Cursor hooks):"
  log "  claude plugin marketplace add alexgreensh/token-optimizer"
  log "  claude plugin install token-optimizer@alexgreensh-token-optimizer"
}

install_cursor() {
  log "Installing Cursor integration..."
  run mkdir -p "${HOME}/.cursor/hooks" "${HOME}/.cursor/rules"
  run cp -f "${REPO_ROOT}/hooks/"*.sh "${HOME}/.cursor/hooks/"
  run cp -f "${REPO_ROOT}/scripts/lib.sh" "${HOME}/.cursor/hooks/lib.sh"
  run cp -f "${REPO_ROOT}/hooks.json" "${HOME}/.cursor/hooks.json"
  run chmod +x "${HOME}/.cursor/hooks/"*.sh
  if [ "$SKIP_RULES" -eq 0 ]; then
    run cp -f "${REPO_ROOT}/rules/"*.mdc "${HOME}/.cursor/rules/"
  fi
  if command -v rtk >/dev/null 2>&1; then
  run rtk init -g --agent cursor --auto-patch 2>/dev/null || log "rtk cursor init skipped (using ccctsk rtk-rewrite.sh)"
  fi
  install_token_optimizer_hint
  if command -v resolve_token_optimizer_root >/dev/null 2>&1; then
    :
  fi
  local to_root
  if to_root="$(resolve_token_optimizer_root 2>/dev/null || true)" && [ -n "$to_root" ]; then
    log "Token Optimizer found at $to_root"
    if [ -f "${to_root}/skills/token-optimizer/scripts/measure.py" ]; then
      run python3 "${to_root}/skills/token-optimizer/scripts/measure.py" setup-daemon 2>/dev/null || true
    fi
  fi
  log "Cursor hooks: ~/.cursor/hooks.json"
}

install_claude() {
  log "Installing Claude Code integration..."
  if ! command -v rtk >/dev/null 2>&1; then
    log "RTK required for Claude — install failed or skipped"
    return 1
  fi
  run rtk init -g --auto-patch
  if command -v claude >/dev/null 2>&1; then
    run claude plugin marketplace add alexgreensh/token-optimizer 2>/dev/null || true
    run claude plugin install token-optimizer@alexgreensh-token-optimizer 2>/dev/null || log "token-optimizer may already be installed"
  else
    install_token_optimizer_hint
  fi
}

install_codex() {
  log "Installing Codex integration..."
  if command -v rtk >/dev/null 2>&1; then
    run rtk init -g --codex --auto-patch 2>/dev/null || run rtk init --codex
  fi
  install_token_optimizer_hint
}

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENTS+=("$2"); shift 2 ;;
    --all) AGENTS+=(cursor claude codex); shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skip-rtk) SKIP_RTK=1; shift ;;
    --skip-caveman) SKIP_CAVEMAN=1; shift ;;
    --skip-rules) SKIP_RULES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [ "${#AGENTS[@]}" -eq 0 ]; then
  AGENTS=(cursor)
fi

log "claude-cursor-codex-token-saver-kit"
log "agents: ${AGENTS[*]}"

if [ "$SKIP_RTK" -eq 0 ]; then
  if [ "$(uname -s)" = "Linux" ]; then
    install_rtk_linux || true
  elif ! command -v rtk >/dev/null 2>&1; then
    log "Install RTK manually: https://github.com/rtk-ai/rtk#installation"
  fi
fi

for agent in "${AGENTS[@]}"; do
  if [ "$SKIP_CAVEMAN" -eq 0 ]; then
    install_caveman_agent "$agent" || log "caveman install for $agent failed (non-fatal)"
  fi
  case "$agent" in
    cursor) install_cursor ;;
    claude) install_claude ;;
    codex) install_codex ;;
    copilot) install_caveman_agent copilot ;;
    *) log "Unknown agent: $agent"; exit 1 ;;
  esac
done

log "Done. Run: ./scripts/doctor.sh"
