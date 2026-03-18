#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERSHELL_SCRIPT_WIN="$(wslpath -w "$SCRIPT_DIR/flutterw.ps1")"

/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoProfile \
  -ExecutionPolicy Bypass \
  -File "$POWERSHELL_SCRIPT_WIN" \
  "$@"
