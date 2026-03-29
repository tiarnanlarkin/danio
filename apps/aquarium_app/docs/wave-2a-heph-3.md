# Wave 2A — Hephaestus Fix Batch 3

**Date:** 2026-03-29  
**Items fixed:** FB-B2, FB-B8

---

## FB-B2: Notification tap — care/water_change payloads unhandled

**File:** `lib/main.dart`  
**Change:** Added `care` and `water_change` cases to `_onNotificationPayload()`.

Both payloads now navigate to **Tab 2 (Tank/Home screen)**, which is the most relevant destination for care reminders and water change notifications. The fix sits alongside the existing `home` case and uses the same tab-switch mechanism (no in-tab push needed).

```dart
} else if (payload == 'care' || payload == 'water_change') {
  // Care reminders and water change notifications → Tank tab
  targetTab = 2;
}
```

---

## FB-B8: Markdown raw in Symptom Triage

**File:** `lib/features/smart/symptom_triage/symptom_triage_screen.dart`  
**Note:** `flutter_markdown` is NOT in `pubspec.yaml`, so used regex stripping instead.

Added a `_stripMarkdown(String text)` helper method that removes:
- ATX headings (`# Heading`)
- Bold/italic markers (`**`, `*`, `__`, `_`)
- Inline code backticks
- Horizontal rules
- Blockquote markers (`>`)
- Converts unordered list markers (`-`, `*`, `+`) → `•` bullets

Applied to:
1. `SelectableText` in `_buildDiagnosisStep` — live streaming display
2. `Navigator.of(context).pop(...)` — journal save value

---

## Analyze Results

```
4 issues found. (ran in 17.7s)
```

All 4 issues are **pre-existing** in `test/widget_tests/tab_navigator_test.dart` (test-only infos/warning, not related to these changes). Zero new issues introduced.
