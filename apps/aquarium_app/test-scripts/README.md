# Danio – Agent-Device Replay Scripts

Deterministic `.ad` replay scripts for the **Danio Aquarium App** (`com.tiarnanlarkin.danio`).

---

## Quick Start

```bash
# Run a single script
agent-device replay test-scripts/onboarding-flow.ad

# Run all scripts
bash test-scripts/run-all.sh
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| `agent-device` installed | `npm i -g agent-device` or follow setup docs |
| Physical Android device **or** emulator | Connected via ADB, USB debugging ON |
| App installed on device | `adb install build/app/outputs/flutter-apk/app-release.apk` |
| ADB visible | `adb devices` should list your device |

---

## Scripts

| Script | What it tests | Pre-condition |
|---|---|---|
| `onboarding-flow.ad` | Full 4-page onboarding → Home screen | **Fresh install** (clear app data first) |
| `tank-creation-flow.ad` | 3-page tank wizard end-to-end | User onboarded, on main nav |
| `learning-flow.ad` | Open lesson → read → quiz → XP | User onboarded, ≥1 lesson unlocked |
| `navigation-flow.ad` | Visit all 5 bottom tabs | User onboarded |
| `calculator-flow.ad` | All 9 Workshop tool cards | User onboarded |
| `settings-flow.ad` | Toolbox hub, Preferences, Achievements, About | User onboarded |
| `edge-case-flow.ad` | Validation, invalid inputs, back nav, quit flow | Scenarios 1–6: onboarded; Scenario 7: fresh install |

---

## .ad Script Format Reference

```
# Comments start with #

open com.tiarnanlarkin.danio --platform android   # Launch app
wait 2000                                          # Wait ms
snapshot                                           # Capture accessibility tree
screenshot /tmp/my-screenshot.png                  # Save screenshot
find "Button label" click                          # Find UI element by text and tap
find_any_of ["Option A", "Option B"] click        # Tap first match
fill "Field label" "value"                         # Type into a text field
clear "Field label"                                # Clear a text field
press back                                         # Hardware back button
scroll_down                                        # Scroll the current view
assert_text "expected text"                        # Fail if text not on screen
assert_no_crash                                    # Fail if the app has crashed
close                                              # Close the app
```

---

## Resetting App State

To run `onboarding-flow.ad` from a completely fresh state:

```bash
adb shell pm clear com.tiarnanlarkin.danio
```

---

## Screenshots

All screenshots are saved to `/tmp/danio-*.png` by default.  
Change the paths in each `.ad` file if you want them persisted elsewhere.

---

## Troubleshooting

**Script fails at `find "..."` — element not found**  
The text label may differ slightly from the code. Open `agent-device snapshot` live to inspect the current UI tree, then update the `find` command.

**"App is not running" error**  
Make sure `adb devices` shows your device and the app is installed. Re-run the `open` step manually to confirm launch.

**Fresh-install scripts stuck on main screen**  
Old profile data wasn't cleared. Run `adb shell pm clear com.tiarnanlarkin.danio` and retry.

---

## Updating Scripts

When UI labels or flows change, update the corresponding `.ad` file.  
Run `agent-device snapshot` against the live app to discover current text labels before editing.
