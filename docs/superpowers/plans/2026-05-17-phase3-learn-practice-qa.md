# Phase 3 Learn Practice QA Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify and polish the Learn, Practice, XP, hearts, progress, and review-reminder experience without reintroducing noisy guidance or automatic notifications.

**Architecture:** Treat Phase 3 as a QA-first pass. The stable interfaces are `LearnScreen`, `LessonScreen`, `PracticeHubScreen`, `SpacedRepetitionNotifier`, `UserProfileNotifier`, and `NotificationScheduler`; changes should be limited to those surfaces or their tests when a concrete issue is found.

**Tech Stack:** Flutter, Riverpod, Android adb on `SM F966B` / `RFCY8022D5R`, local shared preferences inspection, widget/provider/service tests, and debug QA deep links.

---

## File Map

- `apps/aquarium_app/lib/screens/learn/learn_screen.dart`: Learn tab lesson discovery, first-visit guidance, and lesson navigation.
- `apps/aquarium_app/lib/screens/lesson/lesson_screen.dart`: lesson quiz completion, XP awards, heart/energy feedback, review-card seeding, and review reminder scheduling call.
- `apps/aquarium_app/lib/screens/practice_hub_screen.dart`: Practice empty, useful, and due states; first useful guidance; review session entry.
- `apps/aquarium_app/lib/providers/spaced_repetition_provider.dart`: review card seeding, due-card state, session start/completion, and notification scheduling trigger.
- `apps/aquarium_app/lib/providers/user_profile_notifier.dart`: lesson completion, XP/streak/profile updates, and completion persistence.
- `apps/aquarium_app/lib/services/notification_scheduler.dart`: explicit opt-in scheduling gate for review and streak reminders.
- `apps/aquarium_app/lib/services/debug_deep_link_service.dart`: QA-only routes for direct phone review of Learn and Practice states.
- `apps/aquarium_app/test/screens/learn_screen_test.dart`: Learn screen structure and guidance contracts.
- `apps/aquarium_app/test/widget_tests/lesson_screen_test.dart`: lesson flow widget coverage.
- `apps/aquarium_app/test/widget_tests/lesson_reward_sequence_test.dart`: reward, XP, and completion behavior.
- `apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart`: Practice empty/useful/due states and guidance.
- `apps/aquarium_app/test/widget_tests/spaced_repetition_practice_screen_test.dart`: review-session screen behavior.
- `apps/aquarium_app/test/widget_tests/review_session_screen_test.dart`: review session summary/feedback behavior.
- `apps/aquarium_app/test/providers/spaced_repetition_provider_test.dart`: card seeding and scheduling state.
- `apps/aquarium_app/test/providers/user_profile_xp_level_test.dart`: XP and level behavior.
- `apps/aquarium_app/test/services/notification_scheduler_test.dart`: notification opt-in contracts.
- `apps/aquarium_app/test/widget_tests/notification_settings_screen_test.dart`: notification setting toggles.
- `apps/aquarium_app/docs/qa/whole-app-phone-review-phase3-2026-05-17.md`: Phase 3 result log and phone checklist.
- `apps/aquarium_app/docs/qa/screenshots/phase3-2026-05-17/`: screenshots captured during phone review.

---

### Task 1: Baseline Learn And Practice Contracts

**Files:**
- Read: `apps/aquarium_app/lib/screens/learn/learn_screen.dart`
- Read: `apps/aquarium_app/lib/screens/lesson/lesson_screen.dart`
- Read: `apps/aquarium_app/lib/screens/practice_hub_screen.dart`
- Read: `apps/aquarium_app/lib/providers/spaced_repetition_provider.dart`
- Read: `apps/aquarium_app/lib/services/notification_scheduler.dart`
- Modify only if a concrete test or phone failure is found.

- [ ] **Step 1: Run focused widget and provider tests**

Run from `apps/aquarium_app`:

```powershell
flutter test test\screens\learn_screen_test.dart --reporter expanded
flutter test test\widget_tests\lesson_screen_test.dart --reporter expanded
flutter test test\widget_tests\lesson_reward_sequence_test.dart --reporter expanded
flutter test test\widget_tests\practice_hub_screen_test.dart --reporter expanded
flutter test test\widget_tests\spaced_repetition_practice_screen_test.dart --reporter expanded
flutter test test\widget_tests\review_session_screen_test.dart --reporter expanded
flutter test test\providers\spaced_repetition_provider_test.dart test\providers\user_profile_xp_level_test.dart --reporter expanded
flutter test test\services\notification_scheduler_test.dart test\widget_tests\notification_settings_screen_test.dart --reporter expanded
```

Expected: every command exits `0`. Record failures verbatim in `apps/aquarium_app/docs/qa/whole-app-phone-review-phase3-2026-05-17.md`.

- [ ] **Step 2: Check static analysis**

Run from `apps/aquarium_app`:

```powershell
flutter analyze --no-pub
```

Expected: exits `0`.

- [ ] **Step 3: Classify any failure before editing**

Use this classification:

```text
P0: crash, data loss, cannot complete lesson/review flow.
P1: major confusion or broken primary action.
P2: visible layout/copy issue that hurts trust.
P3: nice-to-have improvement.
```

Only edit code for P0, P1, or clear P2 issues found in tests or phone review.

---

### Task 2: Phone Build And State Setup

**Files:**
- Create or update: `apps/aquarium_app/docs/qa/whole-app-phone-review-phase3-2026-05-17.md`
- Create screenshots in: `apps/aquarium_app/docs/qa/screenshots/phase3-2026-05-17/`

- [ ] **Step 1: Confirm connected phone**

Run:

```powershell
flutter devices
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R get-state
```

Expected: `SM F966B` is listed and adb returns `device`.

- [ ] **Step 2: Build and install debug APK**

Run from `apps/aquarium_app`:

```powershell
flutter build apk --debug --target-platform android-arm64
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R install -r build\app\outputs\flutter-apk\app-debug.apk
```

Expected: build exits `0`, install prints `Success`.

- [ ] **Step 3: Capture reminder baseline**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell run-as com.tiarnanlarkin.danio cat shared_prefs/scheduled_notifications.xml
```

Expected: `scheduled_notifications` is `[]` before review reminders are explicitly enabled.

---

### Task 3: Manual Phone Review

**Files:**
- Update: `apps/aquarium_app/docs/qa/whole-app-phone-review-phase3-2026-05-17.md`
- Screenshot output: `apps/aquarium_app/docs/qa/screenshots/phase3-2026-05-17/*.png`

- [ ] **Step 1: Launch and capture Learn**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R logcat -c
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell monkey -p com.tiarnanlarkin.danio -c android.intent.category.LAUNCHER 1
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell am start -a android.intent.action.VIEW -d "danio://qa/learn"
```

Expected: Learn opens directly, any first-visit guidance is compact, no Tank XP nudge or unrelated banner appears.

- [ ] **Step 2: Inspect Practice empty or useful state**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell am start -a android.intent.action.VIEW -d "danio://qa/practice"
```

Expected: if there are no cards, Practice asks the user to finish a Learn lesson; if cards exist, guidance appears at most once and only because there is something to act on.

- [ ] **Step 3: Inspect seeded review session**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell am start -a android.intent.action.VIEW -d "danio://qa/practice-session?path=nitrogen_cycle"
```

Expected: review question, answer choices, heart/status area, and primary action fit inside the phone viewport without bottom-dock overlap.

- [ ] **Step 4: Complete one review interaction**

Use UI tree-derived coordinates:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell uiautomator dump /sdcard/phase3-practice-session.xml
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R pull /sdcard/phase3-practice-session.xml docs\qa\screenshots\phase3-2026-05-17\practice-session.xml
```

Pick the center of a visible answer option and tap it with:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell input tap <x> <y>
```

Expected: answer feedback is stable, no crash is logged, and the next/finish control remains visible.

- [ ] **Step 5: Confirm reminders are still quiet by default**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R shell run-as com.tiarnanlarkin.danio cat shared_prefs/scheduled_notifications.xml
```

Expected: review/streak/onboarding notifications remain unscheduled unless the user has explicitly enabled reminder toggles.

- [ ] **Step 6: Pull logs for app errors**

Run:

```powershell
& "C:\Users\larki\AppData\Local\Android\sdk\platform-tools\adb.exe" -s RFCY8022D5R logcat -d -t 2000 > docs\qa\screenshots\phase3-2026-05-17\phase3-logcat.txt
```

Expected: no `ErrorBoundary caught`, `Global error caught`, `EXCEPTION CAUGHT`, or crash entries from the Learn/Practice flow.

---

### Task 4: Patch Only Concrete Phase 3 Issues

**Files:**
- Modify exact failing surface only after Task 1 or Task 3 identifies a P0/P1/P2 issue.
- Likely test files:
  - `apps/aquarium_app/test/widget_tests/practice_hub_screen_test.dart`
  - `apps/aquarium_app/test/widget_tests/lesson_reward_sequence_test.dart`
  - `apps/aquarium_app/test/providers/spaced_repetition_provider_test.dart`
  - `apps/aquarium_app/test/services/notification_scheduler_test.dart`

- [ ] **Step 1: For guidance noise, write or update a widget test**

The test must assert one of these concrete contracts:

```dart
expect(find.text('Start a quick lesson to earn XP today!'), findsNothing);
expect(find.byType(FirstVisitTooltip), findsAtMostNWidgets(1));
expect(find.textContaining('Practice strengthens concepts'), findsNothing);
```

Use the third assertion only for empty Practice states where `totalCards == 0`.

- [ ] **Step 2: For reminder scheduling, write or update a scheduler test**

The test must assert that disabled reminders cancel and do not schedule:

```dart
await scheduler.scheduleReviewNotificationsForState(
  service: service,
  notificationsEnabled: true,
  reviewRemindersEnabled: false,
  dueCards: 3,
  nextReviewTime: DateTime(2026, 5, 18, 9),
);

expect(service.scheduledIds, isEmpty);
expect(service.cancelledIds, contains(NotificationScheduler.reviewReminderId));
```

- [ ] **Step 3: For layout/action blockers, patch the smallest affected widget**

Common valid fixes:

```dart
SafeArea(
  top: false,
  child: ...
)
```

or:

```dart
SingleChildScrollView(
  padding: EdgeInsets.only(bottom: context.bottomPadding + 16),
  child: ...
)
```

Only use these when the phone screenshot or test output shows clipped content.

- [ ] **Step 4: Rerun the failing targeted command**

Run the exact failing `flutter test ...` command or repeat the exact phone route that exposed the issue.

Expected: the failure is fixed and no new app error appears in logcat.

---

### Task 5: Phase 3 Closeout

**Files:**
- Update: `apps/aquarium_app/docs/qa/whole-app-phone-review-phase3-2026-05-17.md`

- [ ] **Step 1: Run final targeted gate**

Run from `apps/aquarium_app`:

```powershell
flutter analyze --no-pub
flutter test test\screens\learn_screen_test.dart test\widget_tests\lesson_screen_test.dart test\widget_tests\lesson_reward_sequence_test.dart test\widget_tests\practice_hub_screen_test.dart test\widget_tests\spaced_repetition_practice_screen_test.dart test\widget_tests\review_session_screen_test.dart test\providers\spaced_repetition_provider_test.dart test\providers\user_profile_xp_level_test.dart test\services\notification_scheduler_test.dart test\widget_tests\notification_settings_screen_test.dart --reporter expanded
```

Expected: all commands exit `0`.

- [ ] **Step 2: Record final phone result**

Add these fields to the QA note:

```markdown
## Final Result
- Build/commit:
- Device state:
- Automated checks:
- Phone review:
- Reminder state:
- Issues fixed:
- Carry-forward:
```

Expected: all fields contain concrete notes from this run.

- [ ] **Step 3: Report concise pass/fail notes to the user**

Include:

```text
Phase 3 status:
Automated checks:
Phone checks:
Fixes made:
Remaining risks:
Next recommended phase:
```

Do not claim the entire app is release-ready unless Phase 5 has also passed.
