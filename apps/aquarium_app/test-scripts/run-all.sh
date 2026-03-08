#!/usr/bin/env bash
# ============================================================
# run-all.sh — Run all Danio agent-device replay scripts
#
# Usage:
#   bash test-scripts/run-all.sh
#   bash test-scripts/run-all.sh --stop-on-fail
#
# Options:
#   --stop-on-fail   Abort on first failure (default: keep going)
#   --only <name>    Run only the named script (without .ad extension)
#                    e.g. --only navigation-flow
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOP_ON_FAIL=false
ONLY_SCRIPT=""

# ── Parse args ───────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stop-on-fail) STOP_ON_FAIL=true ;;
    --only)
      ONLY_SCRIPT="$2"
      shift
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# ── Colour helpers ───────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

pass() { echo -e "${GREEN}  ✓ PASS${NC}  $1"; }
fail() { echo -e "${RED}  ✗ FAIL${NC}  $1"; }
info() { echo -e "${CYAN}  →${NC} $1"; }

# ── Script list (ordered by dependency) ──────────────────────
SCRIPTS=(
  "onboarding-flow"
  "tank-creation-flow"
  "learning-flow"
  "navigation-flow"
  "calculator-flow"
  "settings-flow"
  "edge-case-flow"
)

# ── Check agent-device is installed ──────────────────────────
if ! command -v agent-device &>/dev/null; then
  echo -e "${RED}ERROR:${NC} 'agent-device' not found in PATH."
  echo "Install with: npm i -g agent-device"
  exit 1
fi

# ── Check ADB device attached ─────────────────────────────────
if ! adb devices 2>/dev/null | grep -q "device$"; then
  echo -e "${YELLOW}WARNING:${NC} No ADB device/emulator detected."
  echo "Connect a device or start an emulator before running."
fi

# ── Run ──────────────────────────────────────────────────────
PASS=0
FAIL=0
SKIP=0
FAILED_SCRIPTS=()

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Danio QA – agent-device replay suite"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════"
echo ""

for NAME in "${SCRIPTS[@]}"; do
  AD_FILE="$SCRIPT_DIR/${NAME}.ad"

  # Skip if --only was specified and this isn't the one
  if [[ -n "$ONLY_SCRIPT" && "$NAME" != "$ONLY_SCRIPT" ]]; then
    SKIP=$((SKIP + 1))
    continue
  fi

  if [[ ! -f "$AD_FILE" ]]; then
    echo -e "${YELLOW}  ? SKIP${NC}  ${NAME}.ad (file not found)"
    SKIP=$((SKIP + 1))
    continue
  fi

  info "Running: ${NAME}.ad"
  START=$(date +%s)

  if agent-device replay "$AD_FILE" 2>&1; then
    END=$(date +%s)
    pass "${NAME}  ($(( END - START ))s)"
    PASS=$((PASS + 1))
  else
    END=$(date +%s)
    fail "${NAME}  ($(( END - START ))s)"
    FAIL=$((FAIL + 1))
    FAILED_SCRIPTS+=("$NAME")

    if [[ "$STOP_ON_FAIL" == "true" ]]; then
      echo ""
      echo "Stopping on first failure (--stop-on-fail)."
      break
    fi
  fi

  # Brief pause between scripts so device settles
  sleep 2
done

# ── Summary ──────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
printf "  Results:  ${GREEN}%d passed${NC}  ${RED}%d failed${NC}  ${YELLOW}%d skipped${NC}\n" \
  "$PASS" "$FAIL" "$SKIP"

if [[ ${#FAILED_SCRIPTS[@]} -gt 0 ]]; then
  echo ""
  echo "  Failed scripts:"
  for s in "${FAILED_SCRIPTS[@]}"; do
    echo -e "    ${RED}✗${NC} ${s}.ad"
  done
fi

echo "═══════════════════════════════════════════════════════"
echo ""

# Exit with non-zero if any failed
[[ $FAIL -eq 0 ]]
