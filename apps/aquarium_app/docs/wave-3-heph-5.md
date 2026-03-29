# Wave 3 — Hephaestus Fix 5: RF-8 Anomaly Dismiss Semantics

## Summary

**File changed:** `lib/screens/smart_screen.dart`

## What Was Fixed

### RF-8 — Anomaly dismiss semantics

**Problem:** The `_showAnomalyHistory` bottom sheet displayed anomaly tiles with a terse `· dismissed` label for dismissed anomalies. There was also no dismiss button in the UI — the `dismiss()` method existed in `AnomalyHistoryNotifier` but was never called from the UI.

**Changes made:**

1. **Dismiss button added** — Each active (non-dismissed) anomaly tile now has a `TextButton('Dismiss')` trailing widget. Tapping it calls `anomalyHistoryProvider.notifier.dismiss(a.id)`.

2. **Dismissed state message** — When an anomaly is dismissed, its subtitle now reads:
   `<parameter> · <time> · Dismissed — will flag again if detected.`
   replacing the old `· dismissed` shorthand.

3. **Reactive sheet** — The `showAppScrollableSheet` builder now wraps its content in a `Consumer` that watches `anomalyHistoryProvider`, so the sheet rebuilds immediately when a user taps Dismiss (without needing to close and reopen).

## Re-flagging Semantics

Re-flagging works correctly by design. `AnomalyHistoryNotifier.addAll()` prepends new `Anomaly` instances to the list — each new detection is a fresh object with `dismissed: false`. Dismissing an old entry marks only that specific instance. If the same parameter anomaly is detected on the next water test log, a new entry is added and shown as active.

## Analyze Results

```
flutter analyze --no-pub
8 issues found (all pre-existing test file issues — 0 in lib/)
```

Pre-existing test issues:
- `test/widget_tests/theme_gallery_screen_test.dart` — references a screen that no longer exists (3 errors)
- `test/widget_tests/tab_navigator_test.dart` — minor infos/warnings

No new issues introduced by this change.
