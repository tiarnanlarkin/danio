#!/usr/bin/env bash
# qa_smoke.sh — Fast automated QA smoke test for Danio
# Runs ADB commands in sequence, captures screenshots at checkpoints.
# Usage: bash scripts/qa_smoke.sh [device] [output_dir]
#
# Screen: 1080x2400 (emulator-5554)
# Flutter renders its own UI — uiautomator can't see content.
# Verification is via screenshots + logcat crash detection.

set -uo pipefail

ADB="/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
DEVICE="${1:-emulator-5554}"
OUT_DIR="${2:-/tmp/qa_smoke_$(date +%Y%m%d_%H%M%S)}"
PKG="com.tiarnanlarkin.danio"
MAIN_ACTIVITY="com.tiarnanlarkin.danio.MainActivity"

mkdir -p "$OUT_DIR"
PASS=0
FAIL=0
WARN=0
RESULTS=()

# ─── Helpers ───────────────────────────────────────────────

adb_cmd() { "$ADB" -s "$DEVICE" "$@"; }

tap() {
  local x=$1 y=$2 label="${3:-tap}"
  adb_cmd shell input tap "$x" "$y" 2>/dev/null
  sleep 0.4
}

swipe_left() {
  adb_cmd shell input swipe 800 1200 200 1200 200 2>/dev/null
  sleep 0.5
}

swipe_up() {
  adb_cmd shell input swipe 540 1800 540 600 300 2>/dev/null
  sleep 0.5
}

type_text() {
  # adb input text works with Flutter text fields when focused
  adb_cmd shell input text "$1" 2>/dev/null
  sleep 0.5
}

press_back() {
  adb_cmd shell input keyevent KEYCODE_BACK 2>/dev/null
  sleep 0.5
}

screenshot() {
  local name="$1"
  local path="$OUT_DIR/${name}.png"
  adb_cmd exec-out screencap -p > "$path" 2>/dev/null
  local size
  size=$(stat -c%s "$path" 2>/dev/null || echo "0")
  if [ "$size" -gt 1000 ]; then
    echo "📸 $name ($((size/1024))KB)"
  else
    echo "⚠️  $name — screenshot may be empty"
  fi
}

check_no_crash() {
  local label="$1"
  local crashes
  crashes=$(adb_cmd shell "logcat -d -t 100 | grep -i 'FATAL\|assertion.*failed\|═══.*EXCEPTION'" 2>/dev/null | tail -3 || true)
  if [ -z "$crashes" ]; then
    echo "✅ $label — no crashes"
    RESULTS+=("✅ $label")
    ((PASS++))
  else
    echo "❌ $label — CRASH DETECTED"
    echo "   $crashes"
    RESULTS+=("❌ $label — CRASH")
    screenshot "CRASH_${label// /_}"
    ((FAIL++))
  fi
}

log_section() {
  echo ""
  echo "── $1 ──"
}

# ─── Pre-flight ────────────────────────────────────────────

log_section "PRE-FLIGHT"
echo "Device: $DEVICE | Output: $OUT_DIR | $(date -u '+%H:%M:%S UTC')"

if ! adb_cmd get-state >/dev/null 2>&1; then
  echo "❌ FATAL: Device $DEVICE not connected"
  exit 1
fi

# Clear logcat + app data for clean state
adb_cmd logcat -c 2>/dev/null || true
adb_cmd shell pm clear "$PKG" 2>/dev/null || true
sleep 1

# Launch
adb_cmd shell am start -n "$PKG/$MAIN_ACTIVITY" 2>/dev/null
sleep 3
screenshot "01_launch"
check_no_crash "App launch"

# ─── Phase 1: Onboarding (3 slides) ───────────────────────

log_section "ONBOARDING"

# Slide 1 → "Continue" button at bottom
tap 540 2200 "Continue (slide 1)"
sleep 1
screenshot "02_slide2"

# Slide 2 → "Continue"
tap 540 2200 "Continue (slide 2)"
sleep 1

# Slide 3 → "Get Started"
tap 540 2200 "Get Started (slide 3)"
sleep 2
screenshot "03_quiz_start"
check_no_crash "Onboarding slides"

# ─── Phase 2: Quiz (4 questions, auto-advance on select) ──

log_section "QUIZ"

# Quiz answers are stacked vertically, centered at x=540
# Option positions roughly: y=800, y=1000, y=1200, y=1400
# Selecting an answer auto-advances to next question

# Q1: "Have you kept fish before?" — tap first option
tap 540 850 "Q1 answer"
sleep 1.5

# Q2: "How familiar with water parameters?" — tap first option
tap 540 850 "Q2 answer"
sleep 1.5

# Q3: "What type of tank?" — tap first option
tap 540 850 "Q3 answer"
sleep 1.5

# Q4: "How often maintenance?" — tap first option
tap 540 850 "Q4 answer"
sleep 2

screenshot "04_quiz_results"
check_no_crash "Quiz completion"

# Results screen → "Start My Journey!" button at bottom
tap 540 2200 "Start My Journey"
sleep 2
screenshot "05_post_journey"

# ─── Phase 3: Tank Creation (CRITICAL PATH) ───────────────

log_section "TANK CREATION (CRITICAL)"

screenshot "06_tank_start"

# Helper: tap Flutter text field by sweeping y positions
# Flutter text fields don't always respond to a single tap at the expected coordinate.
# Sweep a range to ensure focus.
focus_text_field() {
  local label="${1:-text field}"
  for y in 500 600 700 800 900 1000 1100 1200; do
    adb_cmd shell input tap 540 "$y" 2>/dev/null
    sleep 0.15
  done
  sleep 0.5
  echo "🎯 $label — focus sweep done"
}

# Step 1: Name Your Tank
sleep 2
focus_text_field "Name field"
adb_cmd shell input text "SmokeTest" 2>/dev/null
sleep 1
screenshot "07_name_entered"

# Tap Next — sweep bottom area
tap 540 1460 "Next (name)"
sleep 0.5
tap 540 1500 "Next (name alt)"
sleep 2

# Step 2: Tank Size
focus_text_field "Size field"
adb_cmd shell input text "30" 2>/dev/null
sleep 1
screenshot "08_size_entered"

# Tap Next
tap 540 1460 "Next (size)"
sleep 0.5
tap 540 1500 "Next (size alt)"
sleep 2

# Step 3: Water Type — tap first card option (sweep)
tap 540 600 "Water type option 1"
sleep 0.5
tap 540 700 "Water type option 1 alt"
sleep 0.5
tap 540 800 "Water type option 1 alt2"
sleep 2
screenshot "09_water_type"

# Step 4: Confirmation — tap "Create Tank!" at bottom
tap 540 1460 "Create Tank"
sleep 0.5
tap 540 1500 "Create Tank alt"
sleep 0.5
tap 540 2200 "Create Tank alt2"
sleep 3

screenshot "10_POST_CREATE"
check_no_crash "🔴 Tank creation (P0 crash area)"

# ─── Phase 4: Tab Navigation ──────────────────────────────

log_section "TAB NAVIGATION"

# Bottom tab bar: 5 tabs across 1080px, y≈2320
# Tab centers: Learn≈108 Tank≈324 Practice≈540 Smart≈756 Toolbox≈972
TAB_Y=2320

declare -a TAB_NAMES=("Learn" "Tank" "Practice" "Smart" "Toolbox")
declare -a TAB_X=(108 324 540 756 972)

for i in 0 1 2 3 4; do
  tap "${TAB_X[$i]}" "$TAB_Y" "${TAB_NAMES[$i]} tab"
  sleep 1.5
  screenshot "11_tab_${TAB_NAMES[$i],,}"
  check_no_crash "${TAB_NAMES[$i]} tab"
done

# ─── Phase 5: Tank Detail ─────────────────────────────────

log_section "TANK DETAIL"

# Go to Tank tab and try to open the tank
tap 324 "$TAB_Y" "Tank tab"
sleep 1.5
tap 540 800 "Tank card"
sleep 2
screenshot "12_tank_detail"
check_no_crash "Tank detail"
press_back
sleep 1

# ─── Phase 6: Scroll test ─────────────────────────────────

log_section "REGRESSION"

tap 108 "$TAB_Y" "Learn tab"
sleep 1.5
swipe_up
sleep 1
screenshot "13_learn_scrolled"
check_no_crash "Learn scroll"

# ─── Phase 7: Logcat ──────────────────────────────────────

log_section "LOGCAT"

adb_cmd shell "logcat -d" > "$OUT_DIR/logcat_full.txt" 2>/dev/null || true
grep -i "flutter" "$OUT_DIR/logcat_full.txt" > "$OUT_DIR/logcat_flutter.txt" 2>/dev/null || true

FLUTTER_ERRORS=$(grep -ci "error\|exception\|fatal\|assertion" "$OUT_DIR/logcat_flutter.txt" 2>/dev/null || true)
FLUTTER_ERRORS=$(echo "$FLUTTER_ERRORS" | tr -d '[:space:]')
FLUTTER_ERRORS="${FLUTTER_ERRORS:-0}"

STORAGE_WRITES=$(grep -c "Storage persisted" "$OUT_DIR/logcat_flutter.txt" 2>/dev/null || true)
STORAGE_WRITES=$(echo "$STORAGE_WRITES" | tr -d '[:space:]')
STORAGE_WRITES="${STORAGE_WRITES:-0}"

echo "Flutter errors: $FLUTTER_ERRORS | Storage writes: $STORAGE_WRITES"

if [ "$FLUTTER_ERRORS" -eq 0 ] 2>/dev/null; then
  echo "✅ Logcat clean"
  RESULTS+=("✅ Logcat clean")
  ((PASS++))
else
  echo "⚠️  $FLUTTER_ERRORS Flutter errors — see logcat_flutter.txt"
  RESULTS+=("⚠️ $FLUTTER_ERRORS Flutter errors")
  ((WARN++))
fi

# ─── Results ───────────────────────────────────────────────

log_section "RESULTS"
echo ""
echo "📊 $PASS pass / $FAIL fail / $WARN warn"
echo ""
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo ""
echo "📁 $OUT_DIR/ ($(ls "$OUT_DIR"/*.png 2>/dev/null | wc -l) screenshots)"

if [ "$FAIL" -gt 0 ]; then
  echo "🔴 FAIL ($FAIL failures)"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "🟡 PASS WITH WARNINGS"
  exit 0
else
  echo "🟢 ALL PASS"
  exit 0
fi
