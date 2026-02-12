# Unused Widgets Report

Generated: 2025-02-11 (Sprint 3.2 Bug Fixes)

The following widgets in `lib/widgets/` are not imported anywhere in the codebase.
They may be intentionally kept for future features or need to be cleaned up.

## Unused Widgets (12 files)

| Widget | Purpose | Recommendation |
|--------|---------|----------------|
| `achievement_notification.dart` | Achievement unlock notifications | **KEEP** - May be needed for in-app notifications |
| `difficulty_badge.dart` | Difficulty level badges | **KEEP** - Useful for lesson difficulty display |
| `friend_activity_widget.dart` | Friend activity feed | **KEEP** - Part of social features roadmap |
| `hearts_overlay.dart` | Hearts/lives overlay animation | **KEEP** - Gamification feature |
| `hobby_desk.dart` | Hobby desk illustration + ItemDetailPopup | **IN USE** - Exports ItemDetailPopup/ItemDetailRow used by home_screen |
| `loading_state.dart` | Loading indicator widget | **KEEP** - Generic utility widget |
| `mini_analytics_widget.dart` | Compact analytics display | Review - May be superseded by gamification_dashboard |
| `optimized_tank_sections.dart` | Performance-optimized tank view | Review - May be from optimization work |
| `stories_card.dart` | Story card display | **KEEP** - Part of stories feature |
| `streak_display.dart` | Streak counter display | Review - May duplicate streak_calendar |
| `tank_card.dart` | Tank card component | Review - May be superseded by room-based tank display |
| `xp_progress_bar.dart` | XP progress bar | **KEEP** - Gamification widget |

## Summary

- **KEEP**: 6 widgets (reserved for future features or general utilities)
- **IN USE**: 1 widget (hobby_desk - exports ItemDetailPopup/ItemDetailRow)
- **REVIEW**: 5 widgets (may be superseded by other implementations)

## Action Items

1. Before deleting any widget, check if it's part of a planned feature
2. Consider consolidating streak_display with streak_calendar
3. Review if hobby_desk and room_scene have overlapping functionality
4. Consider cleaning up if tank_card is truly replaced by room-based tank display

---

To delete unused widgets in the future, run:
```bash
# Verify widget is truly unused
grep -r "import.*widget_name" lib/ --include="*.dart"
grep -r "WidgetClassName" lib/ --include="*.dart"

# If no results, safe to delete
rm lib/widgets/widget_name.dart
```
