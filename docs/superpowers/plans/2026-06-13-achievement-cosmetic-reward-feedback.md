# Achievement Cosmetic Reward Feedback

## Goal

Make achievement-based room-vibe unlocks visible at the moment an achievement is earned, so reward cosmetics feel meaningful rather than silently appearing later in the theme picker.

## Scope

- Pure room-vibe reward mapping from achievement IDs.
- Single achievement unlock dialog reward messaging.
- Batch achievement summary reward messaging.
- Tests for mapping and single-dialog rendering.

## Out of scope

- New decoration inventory.
- Seasonal cosmetic system.
- Changing existing room-vibe unlock requirements.
- Emulator QA while other Codex sessions may be using Android targets.

## Steps

1. Add failing service tests for achievement ID to room-vibe reward mapping.
2. Add failing widget tests for achievement unlock dialog cosmetic messaging.
3. Implement the mapping in `RoomThemeUnlockService`.
4. Render cosmetic reward rows in single and batch achievement unlock UI.
5. Run focused tests.
6. Run `flutter analyze`, full `flutter test`, local truth doc test, debug APK build, and `git diff --check`.
7. Update complete-local audit/backlog docs and commit.

