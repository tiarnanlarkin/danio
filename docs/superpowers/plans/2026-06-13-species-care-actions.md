# Species Care Actions

## Goal

Make fish species detail sheets more actionable by turning existing species data into a short care-action card.

## Scope

- Fish Database species detail sheet.
- Data-derived actions for minimum tank size, group size, water range, compatibility checks, and treatment warnings.
- Widget tests for visible care-action copy.

## Out of scope

- New species content.
- External source/citation trail.
- Add-to-tank or reminder persistence.
- Plant detail parity.

## Steps

1. Add failing widget test for the Care Actions card on a known species.
2. Implement a compact card using existing `SpeciesInfo` fields.
3. Run focused tests.
4. Run `flutter analyze`, full `flutter test`, local truth doc test, debug APK build, and `git diff --check`.
5. Update complete-local docs and commit.

