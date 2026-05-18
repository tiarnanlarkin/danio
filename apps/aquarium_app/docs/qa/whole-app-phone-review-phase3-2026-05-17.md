# Whole-App Phone Review - Phase 3 Learn, Practice, XP, And Progress

## Scope
- Lesson discovery and lesson entry from Learn.
- Lesson completion feedback, XP, energy/hearts, and review-card seeding.
- Practice empty, useful, due, and review-session states.
- Reminder behavior stays explicit opt-in only.
- Quiet-guidance policy stays intact: no floating XP nudges, no stacked tutorial banners.

## Environment
- Date: 2026-05-17
- Branch: `feature/quiet-guidance-notifications`
- App package: `com.tiarnanlarkin.danio`
- Phone: `SM F966B`
- Android: 16
- Device id: `RFCY8022D5R`
- Device state: returning user from Phase 2 unless a reset is explicitly noted.

## Automated Baseline
- `flutter test test\screens\learn_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\lesson_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\lesson_reward_sequence_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\practice_hub_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\spaced_repetition_practice_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\review_session_screen_test.dart --reporter expanded`: pass
- `flutter test test\providers\spaced_repetition_provider_test.dart test\providers\user_profile_xp_level_test.dart --reporter expanded`: pass
- `flutter test test\services\notification_scheduler_test.dart test\widget_tests\notification_settings_screen_test.dart --reporter expanded`: pass
- `flutter analyze --no-pub`: pass

## Phone Checklist
- Learn opens cleanly with compact just-in-time guidance only.
- Lesson entry is clear and the user knows what to do next.
- Lesson/quiz completion gives clear XP/progress feedback without nagging.
- Practice empty state points back to Learn when there are no cards.
- Practice useful state appears only when cards exist.
- Review session layout fits the phone without bottom-dock or safe-area overlap.
- Hearts/energy/progress state is visible but not a persistent interruption.
- Review/streak notifications remain unscheduled while reminder toggles are off.
- No Flutter error or crash appears in logcat during the flow.

## Phone Evidence
- `docs/qa/screenshots/phase3-2026-05-17/learn.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice-session.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice-answer.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice-complete.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice-summary.png`: captured
- `docs/qa/screenshots/phase3-2026-05-17/practice-session.xml`: captured
- `docs/qa/screenshots/phase3-2026-05-17/phase3-logcat.txt`: captured
- `docs/qa/screenshots/phase3-2026-05-17/phase3-app-logcat.txt`: captured

## Findings
- Pass: Learn opened directly with the current lesson card, visible XP/streak state, and no floating Tank XP nudge.
- Pass: Practice empty state clearly sent the user back to Learn and did not show first-use Practice guidance while there were no cards.
- Pass: QA-seeded review session fit the phone viewport. Answer choices, explanation, and `Complete Session` were visible above the Android navigation bar.
- Pass: Completing one review produced event-based achievement feedback, then returned to a stable caught-up Practice state with next review timing.
- Pass: `scheduled_notifications.xml` was `[]` before the phone run and remained `[]` after completing the review session.
- Observation: screenshots show a pink handle on the far-left edge. This is not in the app accessibility tree and SurfaceFlinger logged the overlay layer as `com.sec.android.app.launcher/com.samsung.app.honeyspace.edge.edgepanel.app.CocktailBarService`, so it is the phone's Samsung Edge panel overlay, not Danio UI.
- Observation: app logcat contains normal debug startup noise and device/vendor messages, but no Flutter `ErrorBoundary caught`, `Global error caught`, `EXCEPTION CAUGHT`, or crash for the Learn/Practice flow.

## Fixes
- No product-code fix needed in Phase 3.
- Added this Phase 3 QA record and the executable plan at `docs/superpowers/plans/2026-05-17-phase3-learn-practice-qa.md`.

## Final Result
- Build/commit: `1e1e701d` plus current uncommitted Phase 0-3 QA/worktree changes.
- Device state: returning user from Phase 2, debug APK reinstalled with `adb install -r`.
- Automated checks: targeted Phase 3 tests and `flutter analyze --no-pub` passed before phone review; the same targeted gate passed again after the phone review.
- Phone review: pass for Learn entry, Practice empty state, seeded review session, answer feedback, completion dialog, and caught-up Practice state.
- Reminder state: `scheduled_notifications` stayed `[]`; no review/streak/onboarding reminder was scheduled.
- Issues fixed: none in product code; the only visible sliver was confirmed as a Samsung system overlay.
- Carry-forward: Phase 4 should review Smart, More, notification settings, reminder toggles, backup/restore, and legal/about surfaces.
