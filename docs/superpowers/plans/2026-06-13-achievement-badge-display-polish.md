# Achievement Badge Display Polish

## Goal

Make achievement badge visuals deterministic, polished, and text-safe as part of `CL-P1-002`, without changing saved achievement metadata or broad reward rules.

## Scope

- Achievement detail modal hero icon.
- Achievement detail modal category badge.
- Achievement screen category filter chips.
- Tests proving raw stored icon strings are not rendered as visible text in those surfaces.

## Out of scope

- Rewriting all achievement definitions.
- New achievement mechanics.
- Backend or public release work.

## Steps

1. Add failing widget tests:
   - Detail modal does not render `Achievement.icon` as raw text.
   - Detail modal does not render `AchievementCategory.icon` inside a combined text label.
   - Achievement screen category filters expose plain category labels.
2. Replace raw icon-text rendering with controlled Material icons and plain text labels.
3. Keep accessibility labels explicit and readable.
4. Run focused tests.
5. Run `flutter analyze`, full `flutter test`, local truth doc test, debug APK build, and `git diff --check`.
6. Update current audit/backlog docs and commit.

