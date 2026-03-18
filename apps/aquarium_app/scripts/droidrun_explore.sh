#!/bin/bash
# DroidRun Exploratory Test — Danio Aquarium App
#
# Usage: ./scripts/droidrun_explore.sh [test_name]
# Requires: droidrun installed, emulator running, ANTHROPIC_API_KEY set
#
# Available tests:
#   full_navigation  - Navigate all tabs, verify no crashes
#   learn_flow       - Open Learn tab, start a lesson, complete it
#   tank_flow        - Navigate to Tank tab, explore tank creation
#   settings_flow    - Open Settings, toggle each option

set -e

DEVICE="${DEVICE:-emulator-5554}"
MODEL="${DROIDRUN_MODEL:-claude}"
TEST="${1:-full_navigation}"

echo "🤖 DroidRun Exploratory Test: $TEST"
echo "   Device: $DEVICE"
echo "   Model: $MODEL"
echo ""

case "$TEST" in
  full_navigation)
    droidrun run \
      --device "$DEVICE" \
      --model "$MODEL" \
      "Launch the Danio aquarium app (package: com.tiarnanlarkin.danio). \
       Once the app is open: \
       1. Wait for the app to fully load (you should see a bottom navigation bar with 5 tabs) \
       2. Tap each tab in order: Learn, Practice, Tank, Smart, More \
       3. Wait 2 seconds on each tab to let content load \
       4. After visiting all tabs, go back to the Learn tab \
       5. Report: which tabs loaded successfully, any errors or crashes you observed, \
          and whether the navigation bar stayed visible throughout"
    ;;
    
  learn_flow)
    droidrun run \
      --device "$DEVICE" \
      --model "$MODEL" \
      "Launch the Danio aquarium app. \
       Navigate to the Learn tab (first tab in bottom nav). \
       Look for any lesson cards or learning content. \
       Tap on the first available lesson or learning card. \
       Try to progress through it (tap 'Next', 'Continue', or answer any questions). \
       Report: what content you saw, whether the lesson loaded, any errors or UI issues"
    ;;
    
  tank_flow)
    droidrun run \
      --device "$DEVICE" \
      --model "$MODEL" \
      "Launch the Danio aquarium app. \
       Navigate to the Tank tab (third tab in bottom nav). \
       Look for a way to create a new tank or view existing tanks. \
       If there's an 'Add Tank' or '+' button, tap it. \
       Try to fill in any form fields that appear. \
       Report: what the tank screen shows, whether creation flow works, any errors"
    ;;
    
  settings_flow)
    droidrun run \
      --device "$DEVICE" \
      --model "$MODEL" \
      "Launch the Danio aquarium app. \
       Navigate to the More tab (last/rightmost tab in bottom nav). \
       This should show settings or preferences. \
       Look for toggle switches and try toggling each one. \
       Scroll down to see all options. \
       Report: what settings are available, whether toggles work, any crashes or lag"
    ;;
    
  *)
    echo "Unknown test: $TEST"
    echo "Available: full_navigation, learn_flow, tank_flow, settings_flow"
    exit 1
    ;;
esac
