# CL-QA-001/002 Whole-App Maps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture and document current local phone and tablet whole-app screenshot/XML evidence for CL-QA-001 and CL-QA-002.

**Architecture:** This is a QA evidence slice, not a product behavior change. Use the dedicated Danio phone and tablet AVDs, the locally built debug APK, existing debug QA deep links, local ADB screenshots, UIAutomator XML dumps, and concise repo docs. Keep evidence local-only and record any route gaps honestly.

**Tech Stack:** Flutter debug APK, PowerShell, Android SDK `adb`, UIAutomator XML dumps, Danio debug QA deep links, repo docs under `apps/aquarium_app/docs`.

---

## File Structure

- Create: `apps/aquarium_app/docs/qa/whole-app-phone-map-2026-07-04.md`
  - Current phone CL-QA-001 map, checks run, inventory rows, pass/fail/gap notes, and evidence links.
- Create: `apps/aquarium_app/docs/qa/whole-app-tablet-map-2026-07-04.md`
  - Current tablet CL-QA-002 map, tablet-specific layout notes, pass/fail/gap notes, and evidence links.
- Create files under: `apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`
  - Phone `.png` screenshots, `.xml` UI hierarchy dumps, and trimmed `logcat` evidence.
- Create files under: `apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`
  - Tablet `.png` screenshots, `.xml` UI hierarchy dumps, and trimmed `logcat` evidence.
- Modify: `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md`
  - Add released ownership rows for the phone and tablet QA map evidence.
- Modify: `apps/aquarium_app/docs/agent/SLICE_LOG.md`
  - Add one QA slice row summarizing CL-QA-001/002 evidence and checks.
- Modify: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
  - Replace the handoff next action with the post-map state and any discovered blockers.
- Modify as warranted: `apps/aquarium_app/docs/agent/SCREEN_INVENTORY.md`
  - Replace `Needs evidence` only for surfaces actually captured in this slice.
- Modify as warranted: `apps/aquarium_app/docs/agent/FINISH_MAP.md`
  - Mark phone/tablet whole-app audits complete only if both map docs and evidence are complete enough for the acceptance criteria.
- Modify as warranted: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - Update CL-QA-001/002 status only if the map docs meet the backlog acceptance criteria.

### Task 1: Device Ownership And Local Gate Preflight

**Files:**
- Read: `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md`
- Read: `apps/aquarium_app/docs/agent/LIVE_PREVIEW_WORKFLOW.md`
- Read: `apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md`
- Modify later: `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md`

- [ ] **Step 1: Confirm clean repo state before device interaction**

Run from `apps/aquarium_app`:

```powershell
git status --short -uall
```

Expected: no unrelated dirty files. If dirty files exist, inspect them before touching docs or devices.

- [ ] **Step 2: Announce ownership in the thread**

State that this session is claiming `danio_android_qa_owner` for:

```text
QA-2026-07-04-002
phone: danio_api36 / emulator-5554
tablet: danio_tablet_api36 / emulator-5556
intended evidence:
apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/
apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/
```

- [ ] **Step 3: Check connected devices**

Run:

```powershell
adb devices
```

Expected: `emulator-5554` and `emulator-5556` show `device`. If physical phone `RFCY8022D5R` is still `unauthorized`, leave it alone.

- [ ] **Step 4: Check dedicated phone AVD readiness**

Run:

```powershell
.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180
```

Expected: the selected device resolves to `danio_api36` and is safe to use for Danio.

- [ ] **Step 5: Check dedicated tablet AVD readiness**

Run:

```powershell
.\scripts\run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -DeviceId emulator-5556 -CheckOnly -WaitSeconds 180
```

Expected: the selected device resolves to `danio_tablet_api36` and is safe to use for Danio.

- [ ] **Step 6: Run AndroidPrep if the previous APK is stale or missing**

Run:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

Expected: focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and read-only device visibility pass.

### Task 2: Phone CL-QA-001 Evidence Capture

**Files:**
- Create: `apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`
- Create: `apps/aquarium_app/docs/qa/whole-app-phone-map-2026-07-04.md`

- [ ] **Step 1: Install and launch the debug APK on the phone AVD**

Run:

```powershell
adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-debug.apk
adb -s emulator-5554 shell am start -n com.tiarnanlarkin.danio/.MainActivity
```

Expected: install succeeds and `MainActivity` launches.

- [ ] **Step 2: Run the phone black-box smoke with QA deep links**

Run:

```powershell
.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-phone-2026-07-04
```

Expected: script exits 0 and reports `Android black-box smoke passed.`

- [ ] **Step 3: Capture phone screenshots and XML for the map surfaces**

For each screen reached manually or by `danio://qa/...`, save a paired `.png` and `.xml` under:

```text
apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/
```

Use descriptive names such as:

```text
phone-01-learn-root.png
phone-01-learn-root.xml
phone-02-practice-root.png
phone-02-practice-root.xml
phone-03-tank-root.png
phone-03-tank-root.xml
phone-04-smart-root.png
phone-04-smart-root.xml
phone-05-more-root.png
phone-05-more-root.xml
phone-06-workshop-root.png
phone-06-workshop-root.xml
phone-07-preferences-root.png
phone-07-preferences-root.xml
phone-08-create-tank.png
phone-08-create-tank.xml
phone-09-lesson.png
phone-09-lesson.xml
phone-10-lesson-quiz.png
phone-10-lesson-quiz.xml
phone-11-practice-session.png
phone-11-practice-session.xml
phone-12-achievements.png
phone-12-achievements.xml
phone-13-species-browser.png
phone-13-species-browser.xml
phone-14-plant-browser.png
phone-14-plant-browser.xml
phone-15-compare-tanks.png
phone-15-compare-tanks.xml
phone-16-glossary.png
phone-16-glossary.xml
phone-17-faq.png
phone-17-faq.xml
```

Expected: each `.png` is non-empty and each `.xml` contains a `<hierarchy>` root.

- [ ] **Step 4: Capture phone crash signature log excerpt**

Run:

```powershell
adb -s emulator-5554 logcat -d -t 5000 > docs\qa\screenshots\2026-07-04\cl-qa-001-phone-whole-app-map\phone-logcat-tail.txt
rg -n "FATAL EXCEPTION|AndroidRuntime|E/flutter|RenderFlex overflowed|ANR" docs\qa\screenshots\2026-07-04\cl-qa-001-phone-whole-app-map\phone-logcat-tail.txt
```

Expected: no matching crash or layout-overflow signatures. If matches exist, record them in the phone map doc.

- [ ] **Step 5: Write the phone map doc**

Create `apps/aquarium_app/docs/qa/whole-app-phone-map-2026-07-04.md` with:

```markdown
# Danio CL-QA-001 Phone Whole-App Map

Date: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Device: `danio_api36`, `emulator-5554`
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Scope: Current phone screenshot/XML audit against the complete-local bar.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| AndroidPrep | Pass | Fill with the exact command result. |
| Phone black-box smoke with QA deep links | Pass | Fill with the exact command result. |
| Crash signature scan | Pass | Fill with the exact grep result. |

## Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Learn root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-01-learn-root.png` / `.xml` | Pass | Fill after visual review. |
```

Continue the table for every captured surface and add `Gap` rows for inventory surfaces not captured.

### Task 3: Tablet CL-QA-002 Evidence Capture

**Files:**
- Create: `apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`
- Create: `apps/aquarium_app/docs/qa/whole-app-tablet-map-2026-07-04.md`

- [ ] **Step 1: Install and launch the debug APK on the tablet AVD**

Run:

```powershell
adb -s emulator-5556 install -r build\app\outputs\flutter-apk\app-debug.apk
adb -s emulator-5556 shell am start -n com.tiarnanlarkin.danio/.MainActivity
```

Expected: install succeeds and `MainActivity` launches.

- [ ] **Step 2: Run a tablet black-box smoke if the UIAutomator route checks remain stable**

Run:

```powershell
.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5556 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-tablet-2026-07-04
```

Expected: script exits 0. If fixed-coordinate swipes make this unstable on tablet, stop the script, save failure artifacts, and use manual screenshot/XML capture while recording the script limitation in the tablet map doc.

- [ ] **Step 3: Capture tablet screenshots and XML for the same surface set**

For each screen, save paired evidence under:

```text
apps/aquarium_app/docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/
```

Use names matching the phone set with `tablet-` prefixes.

Expected: each `.png` is non-empty and each `.xml` contains a `<hierarchy>` root.

- [ ] **Step 4: Capture tablet crash signature log excerpt**

Run:

```powershell
adb -s emulator-5556 logcat -d -t 5000 > docs\qa\screenshots\2026-07-04\cl-qa-002-tablet-whole-app-map\tablet-logcat-tail.txt
rg -n "FATAL EXCEPTION|AndroidRuntime|E/flutter|RenderFlex overflowed|ANR" docs\qa\screenshots\2026-07-04\cl-qa-002-tablet-whole-app-map\tablet-logcat-tail.txt
```

Expected: no matching crash or layout-overflow signatures. If matches exist, record them in the tablet map doc.

- [ ] **Step 5: Write the tablet map doc**

Create `apps/aquarium_app/docs/qa/whole-app-tablet-map-2026-07-04.md` with the same structure as the phone map and tablet-specific notes for rail/sidebar behavior, wrapping, clipped text, and dense states.

### Task 4: Update Agent Control Docs

**Files:**
- Modify: `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md`
- Modify: `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- Modify: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- Modify as warranted: `apps/aquarium_app/docs/agent/SCREEN_INVENTORY.md`
- Modify as warranted: `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- Modify as warranted: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Record released phone/tablet ownership**

Add rows to `DEVICE_OWNERSHIP.md` for `QA-2026-07-04-002`, with `Released` set to `Yes` after capture is complete.

- [ ] **Step 2: Add the slice log row**

Add one row to `SLICE_LOG.md` summarizing:

```text
CL-QA-001 phone map
CL-QA-002 tablet map
AndroidPrep result
black-box smoke result
evidence folders
open blockers or gaps
```

- [ ] **Step 3: Update active handoff**

Set the handoff status to the post-map state. If both maps are complete, recommend the next blocker from the maps. If a device/tooling issue blocks completion, make that the next action with exact device serial and failure artifact path.

- [ ] **Step 4: Update inventory and finish status only for proven evidence**

Replace `Needs evidence` entries in `SCREEN_INVENTORY.md` only where this slice captured current phone/tablet evidence. Mark CL-QA-001/002 complete in `FINISH_MAP.md` and the backlog only if both map docs log every required surface with pass/fail/gap notes.

### Task 5: Verification And Clean Checkpoint

**Files:**
- Verify all changed docs and evidence paths.

- [ ] **Step 1: Run documentation checks**

Run from `apps/aquarium_app`:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart
flutter analyze
```

Expected: all pass. If `flutter analyze` is too slow after a fresh AndroidPrep run, record the last successful AndroidPrep/analyze result and run it unless time or tooling fails.

- [ ] **Step 2: Inspect final worktree**

Run from repo root:

```powershell
git status --short -uall
```

Expected: only planned docs/evidence files are dirty.

- [ ] **Step 3: Release device ownership**

Do not kill or wipe either emulator. State in the final summary that phone and tablet ownership were released.

## Self-Review

- Spec coverage: The plan covers CL-QA-001, CL-QA-002, device ownership, local screenshot/XML evidence, crash signature checks, and repo tracking docs.
- Placeholder scan: No `TBD`, `TODO`, or unspecified implementation steps are left. Surfaces not captured must be explicitly logged as `Gap` in the map docs.
- Type consistency: File paths, slice id `QA-2026-07-04-002`, device ids, and evidence directories are used consistently.
