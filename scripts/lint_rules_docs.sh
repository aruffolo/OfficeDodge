#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "Checking ai-rules for unresolved template placeholders and stale references..."

rg -n '\[\[CODEX:[^\]]+\]\]' ai-rules && {
  echo "Found unresolved template placeholders." >&2
  exit 1
} || true

rg -n 'TODO\(' ai-rules && {
  echo "Found unresolved TODO markers in ai-rules." >&2
  exit 1
} || true

rg -n 'LiqueurCraft|Ricette|AgingCalendar|MyBar|Preparations|Paywall|RouterSpy|IngredientUnit|NumberFormatting|AppFont\.heading' ai-rules && {
  echo "Found stale template/domain references in ai-rules." >&2
  exit 1
} || true

echo "ai-rules lint passed."
