# Screen Scan Results

**Scan Date:** 2025-01-20  
**Total Files Scanned:** 83 screen files in `lib/screens/`  
**Scan Scope:** TODOs, incomplete implementations, coming soon features, hardcoded strings, inconsistent patterns, loading/error/empty states, accessibility issues

---

## Summary Statistics

| Category | Count |
|----------|-------|
| TODO/FIXME Comments | 2 |
| "Coming Soon" Features | 9 instances (5 features) |
| Empty Callbacks (Incomplete) | 8 |
| Placeholder/Stub Code | 24 |
| Screens WITHOUT AppCard | 49/83 (inconsistent) |
| Loading State Indicators | 49 uses of progress indicators |
| Try/Catch Error Handling | 102 instances |
| Semantics Usage | 55 instances (limited to 1 screen) |
| Tooltips | 30+ buttons with tooltips |
| Hardcoded Colors (not AppColors) | 40+ instances |
| Debug Print Statements | 12 |

---

## 🔴 P0 - Critical Issues

### 1. Empty Callbacks - Non-functional Buttons

**Issue:** Skeleton placeholders and loading states have empty callbacks that could be triggered if users interact during loading.

| File | Line | Code | Suggested Fix |
|------|------|------|---------------|
| `equipment_screen.dart` | 104 | `onEdit: () {}` | Remove interaction from skeleton or add null check |
| `equipment_screen.dart` | 105 | `onService: () {}` | Same |
| `equipment_screen.dart` | 106 | `onHistory: () {}` | Same |
| `equipment_screen.dart` | 107 | `onDelete: () {}` | Same |
| `livestock_screen.dart` | 460 | `onTap: () {}` | Same |
| `livestock_screen.dart` | 461 | `onEdit: () {}` | Same |
| `livestock_screen.dart` | 462 | `onDelete: () {}` | Same |
| `logs_screen.dart` | 196 | `onEdit: () {}` | Same |

**Context:** These are in skeleton/placeholder builders for loading states. While wrapped in `Skeletonizer`, the callbacks could theoretically be triggered.

---

## 🟠 P1 - High Priority Issues

### 2. TODO Comments - Unfinished Features

| File | Line | Comment | Priority |
|------|------|---------|----------|
| `home_screen.dart` | 896 | `// TODO: Implement actual export functionality` | P1 |
| `spaced_repetition_practice_screen.dart` | 45 | `// TODO: Display weak cards count` | P2 |

**Suggested Fix:**
- **home_screen.dart:896**: Implement bulk tank export using `BackupRestoreScreen` patterns
- **spaced_repetition_practice_screen.dart:45**: Uncomment and display weak cards in UI

### 3. "Coming Soon" Features - User-Facing Incomplete Functionality

| Feature | Files Affected | Lines |
|---------|---------------|-------|
| **Marine Tank Support** | `create_tank_screen.dart`, `tank_settings_screen.dart`, `enhanced_tutorial_walkthrough_screen.dart`, `tutorial_walkthrough_screen.dart` | 372, 376, 385, 423, 125, 132, 814, 520 |
| **Export Feature** | `home_screen.dart` | 899 |
| **Premium Themes** | `theme_gallery_screen.dart` | 105, 138, 346 |
| **DIY Projects** | `workshop_screen.dart` | 292 |

**User Impact:** Users see "Coming Soon" messages for features they might expect to work.

**Suggested Fix:** Either implement the features or clearly mark them as "Future Release" in app store description to set expectations.

### 4. Tutorial Disabled Features

| File | Line | Issue |
|------|------|-------|
| `onboarding/enhanced_tutorial_walkthrough_screen.dart` | 448 | `onTap: () {}` with `isDisabled: true` |
| `onboarding/tutorial_walkthrough_screen.dart` | 314 | `onTap: () {}` with `isDisabled: true` |

**Issue:** Marine tank option in tutorial has non-functional tap handler.

---

## 🟡 P2 - Medium Priority Issues

### 5. Inconsistent Pattern Usage - AppCard

**49 of 83 screens do NOT use AppCard** while 34 do. This creates visual inconsistency.

**Screens Using AppCard (34):**
- `acclimation_guide_screen.dart`
- `algae_guide_screen.dart`
- `backup_restore_screen.dart`
- `breeding_guide_screen.dart`
- `co2_calculator_screen.dart`
- `compatibility_checker_screen.dart`
- `difficulty_settings_screen.dart`
- `disease_guide_screen.dart`
- `dosing_calculator_screen.dart`
- `emergency_guide_screen.dart`
- `equipment_guide_screen.dart`
- `feeding_guide_screen.dart`
- `hardscape_guide_screen.dart`
- `lighting_schedule_screen.dart`
- `livestock_screen.dart` (summary card only)
- `maintenance_checklist_screen.dart`
- `nitrogen_cycle_guide_screen.dart`
- `parameter_guide_screen.dart`
- `quarantine_guide_screen.dart`
- `quick_start_guide_screen.dart`
- `species_browser_screen.dart`
- `stocking_calculator_screen.dart`
- `substrate_guide_screen.dart`
- `tank_comparison_screen.dart`
- `tank_detail_screen.dart`
- `tank_volume_calculator_screen.dart`
- `unit_converter_screen.dart`
- `vacation_guide_screen.dart`
- `water_change_calculator_screen.dart`
- And others in guides/

**Screens NOT Using AppCard (49):**
- `about_screen.dart`
- `achievements_screen.dart`
- `activity_feed_screen.dart`
- `add_log_screen.dart`
- `analytics_screen.dart`
- `charts_screen.dart`
- `cost_tracker_screen.dart`
- `create_tank_screen.dart`
- `enhanced_onboarding_screen.dart`
- `enhanced_quiz_screen.dart`
- `faq_screen.dart`
- `friends_screen.dart`
- `friend_comparison_screen.dart`
- `gem_shop_screen.dart`
- `glossary_screen.dart`
- `home_screen.dart`
- `house_navigator.dart`
- `inventory_screen.dart`
- `journal_screen.dart`
- `leaderboard_screen.dart`
- `learn_screen.dart`
- `lesson_screen.dart`
- `livestock_detail_screen.dart`
- `log_detail_screen.dart`
- `logs_screen.dart`
- `notification_settings_screen.dart`
- `onboarding_screen.dart`
- `photo_gallery_screen.dart`
- `placement_result_screen.dart`
- `plant_browser_screen.dart`
- `practice_screen.dart`
- `privacy_policy_screen.dart`
- `reminders_screen.dart`
- `search_screen.dart`
- `settings_screen.dart`
- `shop_street_screen.dart`
- `spaced_repetition_practice_screen.dart`
- `stories_screen.dart`
- `story_player_screen.dart`
- `tank_settings_screen.dart`
- `tasks_screen.dart`
- `terms_of_service_screen.dart`
- `theme_gallery_screen.dart`
- `wishlist_screen.dart`
- `workshop_screen.dart`
- All onboarding/ screens

**Suggested Fix:** Create design guidelines document specifying when to use AppCard. Consider:
- AppCard for content sections in guide screens ✓
- Card widgets for list items ✓
- Raw containers for custom layouts (valid exception)

### 6. Hardcoded Colors (Should Use AppColors)

**40+ instances** of hardcoded `Colors.xyz` instead of theme colors.

**Examples:**
| File | Line | Hardcoded Color | Suggested Replacement |
|------|------|-----------------|----------------------|
| `about_screen.dart` | 42 | `Colors.white` | `AppColors.textOnPrimary` |
| `achievements_screen.dart` | 224 | `Colors.grey` | `AppColors.textHint` |
| `activity_feed_screen.dart` | 162 | `Colors.grey.shade300` | `AppColors.divider` |
| `activity_feed_screen.dart` | 390 | `Colors.amber.shade700` | `AppColors.warning` |
| `algae_guide_screen.dart` | 46-199 | Various `Colors.green`, `Colors.teal` | Custom algae palette or AppColors |
| `analytics_screen.dart` | 221-574 | `Colors.amber`, `Colors.blue`, etc. | Chart-specific palette in AppColors |

**Exception:** Some screens (gem_shop, workshop) intentionally use custom color palettes defined as `class GemShopColors` / `WorkshopColors`. These are acceptable if consistent within the screen.

### 7. Debug Print Statements in Production Code

| File | Line | Statement |
|------|------|-----------|
| `add_log_screen.dart` | 153 | `debugPrint('Could not pre-fill last values: $e');` |
| `add_log_screen.dart` | 910 | `debugPrint('Achievement check failed: $e');` |
| `analytics_screen.dart` | 1056 | `debugPrint('Export failed: $e');` |
| `analytics_screen.dart` | 1105 | `debugPrint('CSV Export failed: $e');` |
| `backup_restore_screen.dart` | 528-623 | Multiple import failure logs |
| `create_tank_screen.dart` | 250 | `debugPrint('Achievement check failed: $e');` |
| `lesson_screen.dart` | 972 | `debugPrint('Achievement check failed: $e');` |
| `terms_of_service_screen.dart` | 228 | `debugPrint('Could not launch terms URL: $e');` |

**Note:** `debugPrint` is removed in release mode, so this is low priority. However, consider using a proper logging service for consistent error tracking.

---

## 🟢 P3 - Low Priority / Nice-to-Have

### 8. Accessibility - Limited Semantics Usage

**Only `create_tank_screen.dart`** has comprehensive `Semantics` widgets (20+ instances). Other screens rely on default widget semantics.

**Screens needing accessibility review:**
- `home_screen.dart` - Complex interactive room scene
- `house_navigator.dart` - Navigation gestures
- `gem_shop_screen.dart` - Tab-based shop
- `charts_screen.dart` - Data visualization
- `analytics_screen.dart` - Graphs and charts

**Suggested Fix:**
1. Add `Semantics` to custom interactive widgets
2. Add `semanticLabel` to icon buttons
3. Consider `ExcludeSemantics` for decorative elements

### 9. Touch Target Sizes

Most interactive elements use standard Material buttons which have appropriate touch targets (48dp minimum). Custom `InkWell`/`GestureDetector` widgets should be audited:

| File | Line | Widget | Check Size |
|------|------|--------|------------|
| `activity_feed_screen.dart` | 299 | `InkWell` | ✓ Appears adequate |
| `charts_screen.dart` | 870 | `InkWell` | Verify chart interaction |
| `home_screen.dart` | 217, 599 | `GestureDetector` | Room scene hotspots |
| `house_navigator.dart` | 229, 247, 349 | `GestureDetector` | Navigation dots |

### 10. Placeholder Code to Review

**Intentional placeholders (acceptable):**
- `SkeletonPlaceholders` usage in loading states ✓
- Premium theme previews in `theme_gallery_screen.dart` ✓

**Review needed:**
| File | Line | Context |
|------|------|---------|
| `about_screen.dart` | 20 | `// App icon placeholder` - Consider using actual app icon |
| `tank_detail_screen.dart` | 54 | `title: Text('Task loading placeholder')` |
| `tank_detail_screen.dart` | 79 | `title: Text(log.title ?? 'Activity placeholder')` |
| `spaced_repetition_practice_screen.dart` | 926 | `// For now, show concept ID as placeholder` |
| `lesson_screen.dart` | 397 | `// Placeholder for future image support` |

---

## ✅ Positive Patterns Found

### Good Loading State Handling
- 49 instances of progress indicators
- Consistent use of `Skeletonizer` for skeleton loading
- `BubbleLoader` custom loader used consistently

### Good Error Handling
- 102 try/catch blocks
- Consistent use of `ErrorState` widget
- `AppFeedback.showError()` for user notifications

### Good Empty State Handling
- `EmptyState` and `EmptyState.withMascot()` widgets used
- Contextual empty states with actionable buttons
- Mascot integration for personality

### Good Context/Mounted Checks
- 30+ instances of `mounted`/`context.mounted` checks before setState
- Proper async operation handling

### Good Dispose Patterns
- Controllers properly disposed in `dispose()` methods
- Tab controllers, animation controllers, scroll controllers all cleaned up

### Good Tooltip Coverage
- 30+ buttons have tooltips for accessibility
- Consistent tooltip usage in app bars and FABs

---

## Recommended Actions by Priority

### Immediate (P0)
1. [ ] Fix empty callbacks in skeleton builders (8 instances)

### This Sprint (P1)  
2. [ ] Implement export functionality in `home_screen.dart`
3. [ ] Display weak cards count in practice screen
4. [ ] Add Marine tank support OR update app description

### Next Sprint (P2)
5. [ ] Create AppColors palette for chart/graph colors
6. [ ] Document when to use AppCard vs custom layouts
7. [ ] Replace hardcoded Colors with AppColors (40+ instances)
8. [ ] Consider structured logging over debugPrint

### Backlog (P3)
9. [ ] Accessibility audit for complex screens
10. [ ] Review touch targets for custom widgets
11. [ ] Clean up placeholder comments

---

## Files Requiring Most Attention

| File | Issues | Priority |
|------|--------|----------|
| `home_screen.dart` | TODO, empty callbacks, hardcoded colors | P1 |
| `equipment_screen.dart` | 4 empty callbacks | P0 |
| `livestock_screen.dart` | 3 empty callbacks | P0 |
| `analytics_screen.dart` | Many hardcoded colors, debug prints | P2 |
| `activity_feed_screen.dart` | Hardcoded colors | P2 |
| `create_tank_screen.dart` | Coming soon, good accessibility (model) | P1 |
| `theme_gallery_screen.dart` | Coming soon premium | P2 |
| `workshop_screen.dart` | Coming soon DIY | P2 |

---

*Report generated by automated scan. Manual review recommended for context-specific issues.*
