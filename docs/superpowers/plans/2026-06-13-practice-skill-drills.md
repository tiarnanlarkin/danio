# Practice Skill Drills Plan

## Goal

Broaden Practice beyond generic SRS sessions by adding clear, actionable drill tracks for:

- Parameter interpretation
- Diagnosis
- Compatibility
- Setup planning
- Emergency decisions

The first slice must be real and testable: drill tiles should be backed by a catalog, infer readiness from unlocked review cards, and launch filtered practice sessions through the existing review screen.

## Scope

- Add a lightweight drill model/service.
- Map drill tracks to existing lesson paths without loading deferred lesson bodies.
- Select relevant review cards for a drill, prioritising due/weak cards and capping session size.
- Add a `startDrillSession` provider entry point that creates a filtered review session.
- Surface a `Skill Drills` section in Practice Hub when the deck has cards.
- Keep the empty Practice deck focused on the Learn-to-Practice loop.

## Tests First

- Pure service tests for catalog completeness, path-based unlocking, and filtered card selection.
- Widget test showing `Skill Drills` and an unlocked drill count in Practice Hub.

## Verification

- `flutter test test/services/practice_drill_service_test.dart`
- `flutter test test/widget_tests/practice_hub_screen_test.dart`
- `flutter test`
- `flutter analyze`
- `flutter build apk --debug --target lib/main.dart`
- `git diff --check`

## Constraints

- Do not use emulator/ADB because other Codex sessions may be using Android devices.
- Do not change the existing SRS scheduling behavior for standard/quick/weak/mixed sessions.
- Keep this slice compatible with the current Practice screen; richer scenario-specific UIs can follow after the drill framework is stable.
