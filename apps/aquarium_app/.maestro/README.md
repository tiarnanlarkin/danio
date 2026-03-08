# 🎭 Maestro Test Flows — Danio Aquarium App

Automated UI test flows for `com.tiarnanlarkin.danio` using [Maestro](https://maestro.mobile.dev/).

---

## Prerequisites

### 1. Install Maestro
```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

Add to PATH if needed (add to `~/.bashrc` or `~/.zshrc`):
```bash
export PATH="$PATH:$HOME/.maestro/bin"
```

Verify installation:
```bash
maestro --version
```

### 2. Device / Emulator
- **Android emulator** running, or physical device connected via ADB
- Verify with: `adb devices`
- **The app must already be installed**: `adb install app-debug.apk`

---

## Running Flows

### Run a single flow
```bash
maestro test .maestro/onboarding.yaml
maestro test .maestro/tab-navigation.yaml
maestro test .maestro/tank-creation.yaml
maestro test .maestro/learning-lesson.yaml
maestro test .maestro/calculators.yaml
maestro test .maestro/settings.yaml
maestro test .maestro/tank-management.yaml
maestro test .maestro/achievements.yaml
maestro test .maestro/edge-cases.yaml
```

### Run all flows
```bash
maestro test .maestro/
```

### Run with screenshot output
```bash
maestro test .maestro/onboarding.yaml --output maestro-output/
```

### Run on a specific device
```bash
maestro test --device <device-id> .maestro/onboarding.yaml
```

---

## Flow Overview

| File | What it tests |
|------|--------------|
| `onboarding.yaml` | First launch → profile creation → placement test → main screen |
| `tab-navigation.yaml` | Navigate through all 5 tabs and verify each loads |
| `tank-creation.yaml` | Create a new tank via the 3-step wizard |
| `learning-lesson.yaml` | Open a lesson, read content, complete quiz, verify XP |
| `calculators.yaml` | Workshop tools: water change, stocking, CO₂, dosing, unit converter, tank volume |
| `settings.yaml` | Preferences toggles, About screen, Backup & Restore |
| `tank-management.yaml` | Open a tank, add a log entry, add livestock, open tank settings |
| `achievements.yaml` | Trophy Case screen, filter/sort, tap achievement for detail |
| `edge-cases.yaml` | Empty states, form validation, rapid back nav, double-back-to-exit |

---

## App Structure (Reference)

The app has 5 bottom-nav tabs:

| Index | Label | Screen |
|-------|-------|--------|
| 0 | Learn | `LearnScreen` — learning paths & lessons |
| 1 | Practice | `PracticeHubScreen` — spaced repetition quiz |
| 2 | Tank | `HomeScreen` — tank management |
| 3 | Smart | `SmartScreen` — AI features |
| 4 | Toolbox | `SettingsHubScreen` — workshop, achievements, settings |

Package ID: `com.tiarnanlarkin.danio`

---

## Tips

- Flows use **text-based selectors** wherever possible (more stable than IDs for Flutter).
- `runFlow: when:` guards handle optional UI states gracefully — flows don't crash if a button isn't visible.
- Run `onboarding.yaml` with `clearState: true` to test from a clean install state.
- Run `tank-creation.yaml` before `tank-management.yaml` if starting from a fresh state.
- Screenshots are saved to the working directory when `takeScreenshot:` commands are present.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `maestro: command not found` | Add `~/.maestro/bin` to PATH |
| `No devices found` | Start emulator or plug in device, run `adb devices` |
| Flow times out | Increase wait time or check for UI changes after app updates |
| Element not found | UI text may have changed — inspect with `maestro studio` |

### Launch Maestro Studio (interactive)
```bash
maestro studio
```
This opens a browser UI for recording and debugging flows interactively.
