# Cost Tracker Currency Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Cost Tracker settings safe for saved or locale currency values outside the built-in dropdown list.

**Architecture:** Keep the current local SharedPreferences persistence. Add a small currency-option helper that always includes the active currency, then use ASCII-safe escape sequences for built-in symbols in source while preserving the same visible UI.

**Tech Stack:** Flutter, Riverpod, SharedPreferences mock tests.

---

### Task 1: Add Failing Cost Tracker Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/cost_tracker_test.dart`

- [ ] **Step 1: Write failing settings resilience test**

Add a widget test that seeds:

```dart
SharedPreferences.setMockInitialValues({
  'cost_tracker_expenses': '[]',
  'cost_tracker_currency': 'CHF',
});
```

Then open Cost Tracker settings and expect no Flutter exception plus a visible `CHF` dropdown value.

- [ ] **Step 2: Clean touched test copy**

Replace group-title em dashes and comments with ASCII-safe punctuation. Keep pound-sign assertions using `\u00A3` string escapes.

- [ ] **Step 3: Run focused RED**

Run:

```powershell
flutter test test/widget_tests/cost_tracker_test.dart
```

Expected: the new test fails because `DropdownButton` receives `CHF` as a value that is not present in its item list.

### Task 2: Implement Currency Option Helper

**Files:**
- Modify: `apps/aquarium_app/lib/screens/cost_tracker_screen.dart`

- [ ] **Step 1: Add default options helper**

Add:

```dart
const _defaultCurrencyOptions = ['\u00A3', r'$', '\u20AC', '\u00A5', r'A$', r'C$'];

List<String> _currencyOptions(String activeCurrency) {
  final options = <String>[];
  final active = activeCurrency.trim();
  if (active.isNotEmpty) {
    options.add(active);
  }
  for (final option in _defaultCurrencyOptions) {
    if (!options.contains(option)) {
      options.add(option);
    }
  }
  return options;
}
```

- [ ] **Step 2: Use helper in settings dropdown**

Replace the hard-coded dropdown item list with `_currencyOptions(_currency)`.

- [ ] **Step 3: Clean source escapes**

Use `\u00A3`, `\u20AC`, and `\u00A5` escapes for source-safe built-in symbols. Replace the expense subtitle bullet with ASCII ` - `.

- [ ] **Step 4: Run focused GREEN**

Run:

```powershell
flutter test test/widget_tests/cost_tracker_test.dart
```

Expected: all Cost Tracker tests pass.

### Task 3: Verify, Document, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Update audit docs**

Record this as CL-P1-006J Cost Tracker currency/settings polish.

- [ ] **Step 2: Run verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
rg -n '[^\x00-\x7F]' apps/aquarium_app/lib/screens/cost_tracker_screen.dart apps/aquarium_app/test/widget_tests/cost_tracker_test.dart docs/superpowers/plans/2026-06-13-cost-tracker-currency-polish.md
```

Expected: analyzer clean, full tests pass, docs truth passes, APK builds, diff check clean, and touched source/test/plan files are ASCII-safe.

- [ ] **Step 3: Commit**

```powershell
git add apps/aquarium_app/lib/screens/cost_tracker_screen.dart apps/aquarium_app/test/widget_tests/cost_tracker_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-cost-tracker-currency-polish.md
git commit -m "fix: polish cost tracker currency settings"
```
