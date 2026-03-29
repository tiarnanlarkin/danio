# Wave 2A — Dead CTAs (Part 2)
**Hephaestus · 2026-03-29**

## FB-B5: "Run Symptom Triage" Button — FIXED ✅

**File:** `lib/screens/smart_screen.dart`

The "Run Symptom Triage" `AppButton` inside `_showAnomalyHistory()` had a `// Navigate to symptom triage` comment but no implementation. Wired it to:

```dart
Navigator.maybePop(ctx);
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const SymptomTriageScreen()),
);
```

Closes the anomaly history sheet, then pushes the full `SymptomTriageScreen`. Import was already present.

---

## FB-B6: "Save to Journal" in Symptom Triage — FIXED ✅

**File:** `lib/features/smart/symptom_triage/symptom_triage_screen.dart`

The button previously called `Navigator.of(context).pop(_diagnosis)` — popping the screen with the diagnosis text as a result, but the caller (smart_screen.dart) never awaited or used that result. Nothing was saved.

**Fix:**
1. Added imports: `log_entry.dart`, `storage_provider.dart`, `tank_provider.dart`
2. Added `_saveToJournal()` async method that:
   - Reads the first available tank via `tanksProvider`
   - Creates a `LogEntry` of type `LogType.observation` with the stripped diagnosis text prefixed by `🩺 Symptom Triage Result`
   - Saves via `storageServiceProvider.saveLog()`
   - Shows a success snackbar and pops the screen
   - Shows a warning snackbar if no tanks exist or on save failure
3. Button now calls `_saveToJournal()` instead of the dead pop

---

## FB-B7: WarmEntryScreen Chevron — FIXED ✅

**File:** `lib/screens/onboarding/warm_entry_screen.dart`

The lesson card in `_buildLessonCard()` had a visible `chevron_right_rounded` icon but no tap handler. The outer Scaffold `GestureDetector` wraps the whole screen but internal `Column`/`Container` widgets can absorb taps without bubbling up in all cases.

**Fix:** Wrapped the lesson card `Container` in a `GestureDetector` with:
- `onTap: () { HapticFeedback.selectionClick(); _callReady(); }`
- Updated `Semantics` label to include `button: true` for accessibility

This ensures an explicit, reliable tap target on the lesson card that transitions the user out of the warm entry screen and into the main app (first lesson path).

---

## Flutter Analyze

```
4 issues found. (ran in 19.6s)
```

All 4 issues are pre-existing in `test/widget_tests/tab_navigator_test.dart` (test-only, not in production code). Zero issues in any of the 3 modified files.
