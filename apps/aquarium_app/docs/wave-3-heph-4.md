# Wave 3 — Hephaestus Batch 4

**Date:** 2026-03-29  
**Analyze result:** 4 issues (all pre-existing test file warnings — zero new errors)

---

## RF-3: Cycling Assistant in Workshop Grid ✅

**Files changed:**
- `lib/screens/workshop_screen.dart`

**What was done:**
- Added `cycling_assistant_screen.dart` import
- Added `tanksProvider` import for tank selection
- Added `_openCyclingAssistant()` method to `_WorkshopScreenState`:
  - Reads tanks; if only one tank, navigates directly
  - If multiple tanks, shows a `SimpleDialog` tank picker first
  - If no tanks, shows a snackbar nudging the user to add one first
- Added `_ToolCard` entry ("Cycling Assistant — Track tank cycle") to the Workshop grid

---

## RF-5: Gate Dual Level-Up Systems ✅

**Files changed:**
- `lib/screens/lesson/lesson_completion_flow.dart`

**What was done:**
- In `showLessonXpAnimation`, when a level-up is detected (currentLevel > levelBeforeLesson), the code now calls `ref.read(levelUpEventProvider.notifier).clearEvent()` **before** showing the `LevelUpDialog`.
- This consumes the provider event so `LevelUpListener` (in `TabNavigator`) stays silent for the same level-up, preventing the double-celebration.
- The lesson-scoped `LevelUpDialog` remains the single celebration that fires.

---

## RF-7: Fish ID "Add to Tank" Flow ✅

**Files changed:**
- `lib/screens/livestock/livestock_add_dialog.dart`
- `lib/features/smart/fish_id/fish_id_screen.dart`

**What was done:**

### LivestockAddDialog
- Added `prefillCommonName` and `prefillScientificName` named parameters
- `initState` uses these values to pre-populate the name/scientific name controllers when not in edit mode
- Also attempts `SpeciesDatabase.lookup()` on the prefill name to auto-select a matching species (for suggestions, schooling defaults, etc.)

### FishIdScreen
- Added imports: `tank_provider.dart`, `models.dart`, `livestock_add_dialog.dart`, `app_bottom_sheet.dart`
- Replaced the `Navigator.of(context).pop(r)` "Add to My Tank" handler with `_addToTank(result)`
- `_addToTank()`:
  1. Reads all tanks via `tanksProvider`
  2. If empty → shows snackbar "Add a tank first"
  3. If one tank → skips picker, uses it directly
  4. If multiple tanks → shows `showAppDialog<Tank>` with a list picker
  5. Opens `LivestockAddDialog` via `showAppDragSheet` with `prefillCommonName` and `prefillScientificName` from the AI result

---

## Notes

- `CyclingAssistantScreen` requires a `tankId` so a tank picker is mandatory — the Workshop entry handles this gracefully.
- The dual level-up guard is minimal: the `LevelUpListener` pattern is still intact for all other level-up paths (e.g., XP from activities, achievements). Only the lesson flow explicitly pre-empts it.
- `LivestockAddDialog.prefillCommonName` / `prefillScientificName` are nullable — all existing callers remain unchanged.
