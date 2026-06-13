# Species Request Path

## Goal

Add a simple, honest request path when users search for a fish that is not in the local species database.

## Scope

- Species browser empty-search state.
- Local dialog explaining what to send and where.
- Tests covering the button and dialog copy.

## Out of scope

- Backend request submission.
- Email client integration.
- New species research/content additions.
- Plant request path.

## Steps

1. Add failing widget tests for empty search request action and dialog.
2. Add a `Request species` action to the empty state.
3. Show a local dialog with the searched name, contact email, and plain copy that nothing is sent automatically.
4. Run focused tests.
5. Run `flutter analyze`, full `flutter test`, local truth doc test, debug APK build, and `git diff --check`.
6. Update complete-local docs and commit.

