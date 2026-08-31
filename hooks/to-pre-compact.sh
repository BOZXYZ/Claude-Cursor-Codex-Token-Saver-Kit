#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/to-common.sh" skills/token-optimizer/scripts/measure.py compact-capture --trigger auto --quiet
