# Wave 3 — Same-Class Sweep Findings

> **Sweep date:** 2026-03-29  
> **Scope:** `lib/` — report only, no fixes applied.

---

## 1. Remaining `print(` statements

**✅ None found.**

`grep -rn 'print(' lib/ | grep -v 'debugPrint\|// '` returned no results.

---

## 2. Remaining duplicate UI entries

**⚠️ Two duplication issues found.**

### 2a. "Shop Street" appears twice in `SettingsScreen` (Preferences)

**File:** `lib/screens/settings/settings_screen.dart`

- Line ~119–125: `ToolsSection` widget is rendered inside the "Tools & Shop" section.
- Line ~126–130: A *separate* `NavListTile` for **Shop Street** is then added immediately after `ToolsSection` ends.

`ToolsSection` (`lib/screens/settings/widgets/tools_section.dart`) does **not** include Shop Street, so this isn't a true duplicate within that screen — but the placement is confusing because the section is labelled "Tools & Shop" yet Shop Street is bolted on outside `ToolsSection`. Worth verifying intent.

### 2b. "Backup & Restore" and "About" appear in both `SettingsHubScreen` and `SettingsScreen`

Users can reach the same destination from two sibling flows:

| Screen | Entry |
|--------|-------|
| `settings_hub_screen.dart` (Tab 3 "More") | "Backup & Restore" tile + "About" tile in App Settings section |
| `settings_screen.dart` (Preferences, reachable from "More → Preferences") | "Backup & Restore" tile + "About" tile in Help & Support section |

Both navigate to `BackupRestoreScreen` and `AboutScreen` respectively. This may be intentional (convenience shortcuts), but it mirrors the pattern flagged in Wave 3 for Settings Hub duplicates and should be reviewed.

---

## 3. Remaining version string hardcodes

**⚠️ One instance found.**

| File | Line | Value | Context |
|------|------|-------|---------|
| `lib/utils/app_constants.dart` | 13 | `'1.0.0'` | `defaultValue: '1.0.0'` in the `kAppVersion` `String.fromEnvironment` call |

```dart
const kAppVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',  // ← hardcoded fallback
);
```

This **is** inside `kAppVersion` itself (the single source of truth), so it doesn't match the pattern of *consuming* a hardcoded version outside `kAppVersion`. However the fallback `'1.0.0'` will be shipped if `--dart-define=APP_VERSION=...` is not passed at build time, potentially causing the version footer (and About screen) to display a stale value in production builds that omit the define. Consider sourcing this from `pubspec.yaml` via a build step instead.

---

## 4. Remaining dead buttons / CTAs

**⚠️ One group of empty callbacks found (skeleton/placeholder context — expected but flagged for completeness).**

| File | Lines | Pattern |
|------|-------|---------|
| `lib/screens/livestock/livestock_screen.dart` | 606, 608, 610 | `onTap: () {}`, `onEdit: () {}`, `onDelete: () {}` |

These are inside `_buildSkeletonList()`, wrapped in `IgnorePointer(child: Skeletonizer(...))`, so they are **non-interactive by design**. No functional dead buttons were found outside skeleton loading states.

No instances of `onPressed: () {}` were found anywhere in `lib/`.

---

## 5. Remaining `TextInputType.number` without decimal option

**⚠️ Three instances found where `TextInputType.number` (integer-only) may need decimal support.**

| File | Line | Field | Assessment |
|------|------|-------|------------|
| `lib/screens/add_log/add_log_screen.dart` | 761 | Custom water-change `%` field | Percentage is typically integer (0–100) — `digitsOnly` formatter present, likely intentional. Low risk. |
| `lib/screens/equipment_screen.dart` | 688 | Maintenance interval (days) | Days is always an integer — `digitsOnly` formatter present. Intentional. |
| `lib/screens/livestock/livestock_add_dialog.dart` | 245 | Livestock count | Fish counts are integers — `digitsOnly` formatter present. Intentional. |

All three use `FilteringTextInputFormatter.digitsOnly` alongside `TextInputType.number`, making the integer restriction explicit and consistent. None are calculator or measurement fields where decimals would be expected. **No changes recommended**, but documented for completeness.
