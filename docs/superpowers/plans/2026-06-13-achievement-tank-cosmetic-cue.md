# Achievement Tank Cosmetic Cue

## Goal

Make earned achievements visibly affect the central aquarium with a small text-free cosmetic cue, using real local profile achievement data.

## Scope

- Pure `TankAchievementVisualService` state from achievement IDs.
- `ThemedAquarium` overlay rendering and semantics.
- `LivingRoomScene` and `HomeScreen` prop wiring.
- Focused service/widget coverage.

## Out of scope

- Full decoration inventory.
- Seasonal themes.
- User-selectable achievement badges.
- New asset generation.

## Steps

1. Add failing service tests for clear, badge shelf, and trophy shelf states.
2. Add failing aquarium widget tests for achievement cosmetic overlay key and semantics.
3. Implement service and aquarium overlay painter.
4. Wire `HomeScreen` profile achievements through `LivingRoomScene` into `ThemedAquarium`.
5. Run focused tests.
6. Run `flutter analyze`, full `flutter test`, local truth doc test, debug APK build, and `git diff --check`.
7. Update complete-local docs and commit.

