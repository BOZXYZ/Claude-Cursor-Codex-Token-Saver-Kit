#!/usr/bin/env bash
# Resolve Token Optimizer plugin install path (latest version under cache).
resolve_token_optimizer_root() {
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "$CLAUDE_PLUGIN_ROOT" ]; then
    printf '%s' "$CLAUDE_PLUGIN_ROOT"
    return 0
  fi
  local base="${HOME}/.claude/plugins/cache/alexgreensh-token-optimizer/token-optimizer"
  if [ ! -d "$base" ]; then
    return 1
  fi
  ls -d "${base}"/*/ 2>/dev/null | sort -V | tail -1 | sed 's:/$::'
}
