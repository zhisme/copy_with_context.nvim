#!/usr/bin/env bash
set -euo pipefail

STARTUP_FILE="${1:-/tmp/st}"

# Parse the startuptime file for the plugin's load time
# Format: "<time_in_ms>: <event>"
LUA_TIME=$(awk '/copy_with_context\.lua/ {print $1; exit}' "$STARTUP_FILE")

if [ -z "$LUA_TIME" ]; then
  echo "⚠️  copy_with_context.lua not found in startuptime output. Skipping budget check."
  exit 0
fi

if awk -v t="$LUA_TIME" 'BEGIN { exit (t < 5.0 ? 0 : 1) }'; then
  echo "✅ Plugin startup time is within budget: ${LUA_TIME}ms < 5.0ms"
else
  echo "❌ Plugin startup time exceeded budget: ${LUA_TIME}ms >= 5.0ms"
  exit 1
fi
