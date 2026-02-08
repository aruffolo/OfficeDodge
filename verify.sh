#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT_DIR/Package"

available_ios_simulator_ids() {
  local ids
  local attempt
  for attempt in 1 2 3; do
    ids=$(
      xcodebuild -showdestinations -scheme OfficeDodge-Package 2>/dev/null \
        | rg 'platform:iOS Simulator' \
        | rg -o '[0-9A-F-]{36}' \
        | awk '!seen[$0]++' || true
    )
    if [[ -n "$ids" ]]; then
      printf '%s\n' "$ids"
      return
    fi
    sleep 1
  done
}

select_destination_id() {
  local available_ids
  local booted_id
  local selected_id

  available_ids=$(available_ios_simulator_ids)
  booted_id=$(xcrun simctl list devices booted 2>/dev/null | rg -m1 -o '[0-9A-F-]{36}' || true)

  if [[ -n "$booted_id" ]] && printf '%s\n' "$available_ids" | rg -q "^${booted_id}$"; then
    echo "$booted_id"
    return
  fi

  selected_id=$(printf '%s\n' "$available_ids" | head -n1 || true)
  if [[ -n "$selected_id" ]]; then
    echo "$selected_id"
    return
  fi
}

if [[ -n "${SIMULATOR_ID:-}" ]]; then
  DESTINATION="platform=iOS Simulator,id=${SIMULATOR_ID}"
else
  DEST_ID=$(select_destination_id)
  if [[ -z "$DEST_ID" ]]; then
    echo "No valid iOS Simulator destination found for OfficeDodge-Package after 3 discovery attempts." >&2
    exit 1
  fi
  DESTINATION="platform=iOS Simulator,id=${DEST_ID}"
fi

xcodebuild test \
  -scheme OfficeDodge-Package \
  -destination "$DESTINATION" \
  -derivedDataPath "$ROOT_DIR/.build/DerivedData"
