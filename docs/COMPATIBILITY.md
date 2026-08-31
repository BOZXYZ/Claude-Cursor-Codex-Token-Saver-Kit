# Compatibility

## Full stack (RTK + Token Optimizer + Caveman)

| Agent | Install flag | Notes |
|---|---|---|
| **Cursor** | `--agent cursor` | Token Optimizer bridged via hooks (no official Cursor plugin yet) |
| **Claude Code** | `--agent claude` | Native plugin support for all three tools |
| **Codex (OpenAI)** | `--agent codex` | RTK + Caveman native; Token Optimizer via Codex hooks |
| **GitHub Copilot** | `--agent copilot` | Partial — Caveman + Copilot TO beta |

## Partial support (RTK + Caveman only)

Gemini CLI, Windsurf, Cline, Qwen Code — install Caveman via `npx skills add JuliusBrussee/caveman -a <agent>` and RTK where hooks exist.

## Not supported

- ChatGPT web / mobile app (no local hooks)
- Kimi (no hook API)
- Generic chat UIs without shell access

## Upstream tools (install separately)

This kit does **not** redistribute third-party code. Users install:

| Tool | License | Install |
|---|---|---|
| [RTK](https://github.com/rtk-ai/rtk) | MIT | Auto on Linux via `install.sh`, or manual |
| [Token Optimizer](https://github.com/alexgreensh/token-optimizer) | PolyForm Noncommercial | Claude Code marketplace plugin |
| [Caveman](https://github.com/JuliusBrussee/caveman) | See upstream | `npx skills add` or Claude plugin |

## Requirements

- bash, jq, python3
- Linux or macOS (Windows: WSL recommended)
- Claude Code CLI (for Token Optimizer plugin install, even when using Cursor)
