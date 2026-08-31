# Claude Cursor Codex Token Saver Kit

**One install. Three agents. Cut shell, context, and output token waste by 50–70%.**

Wires [RTK](https://github.com/rtk-ai/rtk), [Token Optimizer](https://github.com/alexgreensh/token-optimizer), and [Caveman](https://github.com/JuliusBrussee/caveman) for **Cursor**, **Claude Code**, and **Codex** — the AI coding agents that support local hooks.

Built by **[RetailBonds.in](https://retailbonds.in)** — Indian fixed income research platform. We open-sourced our token stack.

## What it does

| Layer | Saves tokens on |
|---|---|
| **RTK** | Shell output (`git`, `grep`, `pytest`, `curl`, …) |
| **Token Optimizer** | Stale file re-reads, bloated tool results, compaction loss |
| **Caveman** | Verbose agent replies (terse mode, code unchanged) |

## Quick start

```bash
git clone https://github.com/BOZXYZ/Claude-Cursor-Codex-Token-Saver-Kit.git
cd Claude-Cursor-Codex-Token-Saver-Kit
chmod +x install.sh scripts/*.sh hooks/*.sh
./install.sh --agent cursor    # or --all
./scripts/doctor.sh
```

### Prerequisites

1. **jq** — `sudo apt install jq` (Debian/Ubuntu)
2. **Token Optimizer** (for Cursor bridge):
   ```bash
   claude plugin marketplace add alexgreensh/token-optimizer
   claude plugin install token-optimizer@alexgreensh-token-optimizer
   ```
3. Restart Cursor / Claude Code after install

## Install options

```bash
./install.sh --agent cursor          # Cursor only (default)
./install.sh --agent claude          # Claude Code
./install.sh --agent codex           # OpenAI Codex
./install.sh --all                   # cursor + claude + codex
./install.sh --agent cursor --dry-run
```

## Verify

```bash
./scripts/doctor.sh

# RTK hook test (Cursor)
echo '{"tool_name":"Shell","tool_input":{"command":"git status"}}' \
  | ~/.cursor/hooks/rtk-rewrite.sh
# Expected: "updated_input": {"command": "rtk git status"}

rtk gain    # cumulative savings
```

## Project-level RTK filters (optional)

```bash
cp filters/filters.toml.example your-repo/.rtk/filters.toml
cd your-repo && rtk trust --yes
```

## Uninstall

```bash
./scripts/uninstall.sh cursor
```

## Compatibility

See [docs/COMPATIBILITY.md](docs/COMPATIBILITY.md).

**Full stack:** Cursor, Claude Code, Codex, Copilot (partial)  
**Not supported:** ChatGPT web, Kimi, agents without hook APIs

## How it works (Cursor)

```
User prompt
    ↓
beforeSubmitPrompt → Token Optimizer (quality, verbosity steer)
    ↓
preToolUse Shell   → RTK rewrite + bash compression
preToolUse Read    → read cache (skip stale re-reads)
    ↓
postToolUse        → archive large results, context intel
    ↓
preCompact         → compaction guidance + checkpoint
    ↓
Caveman rule       → terse agent output
```

## Real numbers (production VPS)

From a live RetailBonds VPS session:

- **RTK:** 16.7M tokens saved (68% on shell commands)
- **Token Optimizer doctor:** 13/13 checks passing
- **Caveman:** ~65% output token reduction (upstream benchmark)

Your mileage varies. Run `rtk gain` and Token Optimizer dashboard to measure.

## License

MIT — this installer and hook glue code only.

Third-party tools retain their own licenses. Token Optimizer is [PolyForm Noncommercial](https://github.com/alexgreensh/token-optimizer) — users must install it themselves.

## Links

- [RetailBonds.in](https://retailbonds.in) — built by
- [RTK](https://github.com/rtk-ai/rtk)
- [Token Optimizer](https://github.com/alexgreensh/token-optimizer)
- [Caveman](https://github.com/JuliusBrussee/caveman)

## Contributing

PRs welcome. Keep it glue-only — don't vendor upstream tool code.
