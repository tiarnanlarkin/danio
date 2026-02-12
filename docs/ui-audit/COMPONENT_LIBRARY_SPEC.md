# Aquarium App Component Library Specification

**Generated:** 2025-02-12  
**Version:** 1.0  
**Status:** Design Phase

---

## Executive Summary

This document specifies a comprehensive, reusable component library for achieving A+ UI consistency across the Aquarium App. The audit identified **40 existing widgets** in `lib/widgets/`, **339 inline private widgets** scattered across screens, and significant opportunities for consolidation.

---

## Table of Contents

1. [Audit Results](#audit-results)
2. [Component Inventory](#component-inventory)
3. [Missing Components](#missing-components)
4. [Component API Specifications](#component-api-specifications)
5. [Implementation Priority](#implementation-priority)
6. [Naming Conventions](#naming-conventions)
7. [Directory Structure](#directory-structure)

---

## Audit Results

### Existing Widget Files (40 files)

| Category | Files | Status |
|----------|-------|--------|
| **State Widgets** | `empty_state.dart`, `error_state.dart`, `loading_state.dart`, `offline_indicator.dart` | ✅ Well-designed, reusable |
| **Skeleton Loaders** | `skeleton_loader.dart` | ✅ Comprehensive, 7 variants |
| **Achievement** | `achievement_card.dart`, `achievement_detail_modal.dart`, `achievement_notification.dart`, `achievement_unlocked_dialog.dart` | ⚠️ Tightly coupled to achievement model |
| **Gamification** | `xp_progress_bar.dart`, `daily_goal_progress.dart`, `streak_calendar.dart`, `streak_display.dart`, `hearts_widgets.dart`, `hearts_overlay.dart`, `confetti_overlay.dart`, `level_up_dialog.dart`, `xp_award_animation.dart` | ⚠️ Good but inconsistent APIs |
| **Cards** | `tank_card.dart`, `stories_card.dart`, `cycling_status_card.dart` | ⚠️ Inconsistent patterns |
| **FAB/Navigation** | `speed_dial_fab.dart`, `room_navigation.dart` | ✅ Well-designed |
| **Scene/Illustrations** | `room_scene.dart`, `study_room_scene.dart`, `hobby_desk.dart`, `hobby_items.dart`, `decorative_elements.dart` | 📦 Feature-specific |
| **Utility** | `optimized_image.dart`, `optimized_tank_sections.dart`, `performance_overlay.dart`, `sync_indicator.dart`, `sync_debug_dialog.dart`, `tutorial_overlay.dart` | ✅ Utility widgets |
| **Dashboard** | `gamification_dashboard.dart`, `quick_start_guide.dart`, `mini_analytics_widget.dart`, `friend_activity_widget.dart`, `difficulty_badge.dart`, `exercise_widgets.dart` | ⚠️ Feature-specific composites |

### Inline Widgets Analysis (339 private widgets)

**Pattern Analysis:**
- **Card variants:** ~45 (`_StepCard`, `_TipCard`, `_AlgaeCard`, `_DiseaseCard`, `_MethodCard`, etc.)
- **List item variants:** ~35 (`_ExpenseTile`, `_ActivityTile`, `_FeatureItem`, `_ChecklistItem`, etc.)
- **Chip/Badge variants:** ~30 (`_TypeChip`, `_ParamChip`, `_Badge`, `_StatChip`, etc.)
- **Form field variants:** ~25 (`_ParameterField`, `_CompactParamField`, `_SizePreset`, etc.)
- **Section/Row variants:** ~40 (`_RefRow`, `_DropCheckerRow`, `_TipRow`, `_ParamRow`, etc.)
- **Selector variants:** ~20 (`_TypeSelector`, `_WaterTypeSelector`, `_FilterBar`, etc.)
- **Empty state variants:** ~15 (custom `_EmptyState` implementations)
- **Other:** ~130 (date dividers, headers, summary cards, etc.)

### Key Issues Identified

1. **Duplication:** Similar card/tile patterns reimplemented 45+ times
2. **Inconsistent APIs:** No standard props for sizing, spacing, variants
3. **Theme Coupling:** Some widgets hardcode colors instead of using AppColors
4. **Accessibility:** Missing semantic labels, contrast checks inconsistent
5. **No Documentation:** Zero inline docs on most private widgets

---

## Component Inventory

### Existing Reusable Components (Keep & Enhance)

```
lib/widgets/
├── states/
│   ├── empty_state.dart          ✅ EmptyState, CompactEmptyState
│   ├── error_state.dart          ✅ ErrorState, CompactErrorState, ErrorBanner
│   ├── loading_state.dart        ✅ LoadingState, ShimmerLoading, LoadingOverlay
│   └── offline_indicator.dart    ✅ OfflineIndicator
│
├── skeletons/
│   └── skeleton_loader.dart      ✅ ShimmerLoading, SkeletonBox, SkeletonCard, 
│                                    SkeletonGrid, SkeletonList, SkeletonChart,
│                                    SkeletonStoryCard, SkeletonAchievementCard
│
├── navigation/
│   ├── speed_dial_fab.dart       ✅ SpeedDialFAB, SpeedDialAction
│   └── room_navigation.dart      ✅ RoomNavigation
│
└── gamification/
    ├── xp_progress_bar.dart      ✅ XpProgressBar, XpProgressCard
    ├── daily_goal_progress.dart  ✅ DailyGoalProgress, DailyGoalCard
    └── confetti_overlay.dart     ✅ ConfettiOverlay
```

### Components in `app_theme.dart` (Keep)

```dart
// Already defined in theme:
GlassCard        // ✅ Glassmorphism card
GradientCard     // ✅ Gradient background card
PillButton       // ✅ Pill-shaped toggle button
StatCard         // ✅ Statistic display card
```

---

## Missing Components

### Priority 1: Foundation Components

#### 1.1 AppButton (Unified Button System)

**Current State:** Using Flutter's `ElevatedButton`, `TextButton`, `OutlinedButton` directly
**Need:** Consistent button variants with app-specific styling

```dart
/// Unified button component with consistent styling
class AppButton extends StatelessWidget {
  // Required
  final String label;
  final VoidCallback? onPressed;
  
  // Variants
  final AppButtonVariant variant; // primary, secondary, text, destructive
  final AppButtonSize size;       // small, medium, large
  
  // Optional
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  
  // States: enabled, disabled, loading, pressed
}

enum AppButtonVariant { primary, secondary, outline, text, destructive }
enum AppButtonSize { small, medium, large }
```

**Accessibility:**
- `semanticsLabel` for screen readers
- Minimum touch target 48x48
- Focus indicators
- Loading state announcements

---

#### 1.2 AppCard (Unified Card System)

**Current State:** 45+ card variants duplicated across screens
**Need:** Composable card with consistent structure

```dart
/// Base card component with standardized structure
class AppCard extends StatelessWidget {
  // Content
  final Widget child;
  
  // Variants
  final AppCardVariant variant;  // elevated, outlined, filled, glass
  final AppCardPadding padding;  // none, compact, standard, spacious
  
  // Optional structure
  final Widget? header;
  final Widget? footer;
  final Widget? leading;
  final Widget? trailing;
  
  // Interaction
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  // Style
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
}

enum AppCardVariant { elevated, outlined, filled, glass }
enum AppCardPadding { none, compact, standard, spacious }
```

**Specialized Card Variants:**
```dart
// Pre-composed cards using AppCard as base:
class InfoCard extends AppCard { ... }      // Icon + title + description
class ActionCard extends AppCard { ... }    // Card with CTA button
class StatisticCard extends AppCard { ... } // Number + label + trend
class MediaCard extends AppCard { ... }     // Image header + content
```

---

#### 1.3 AppListTile (Unified List Item)

**Current State:** 35+ list item variants (`_ExpenseTile`, `_ActivityTile`, etc.)
**Need:** Flexible list item that covers all use cases

```dart
/// Unified list tile for all list contexts
class AppListTile extends StatelessWidget {
  // Content
  final String title;
  final String? subtitle;
  final String? caption;         // Third line or metadata
  
  // Visual
  final Widget? leading;         // Avatar, icon, checkbox, image
  final Widget? trailing;        // Icon, switch, badge, chevron
  
  // Variants
  final AppListTileVariant variant;  // standard, dense, compact, three-line
  
  // Interaction
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isEnabled;
  
  // Swipe actions (optional)
  final List<SwipeAction>? leadingSwipeActions;
  final List<SwipeAction>? trailingSwipeActions;
}

enum AppListTileVariant { standard, dense, compact, threeLine }
```

---

#### 1.4 AppChip & AppBadge

**Current State:** 30+ chip/badge variants scattered
**Need:** Unified chip/badge system

```dart
/// Chip for filters, tags, selections
class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final AppChipVariant variant;   // filter, input, suggestion, action
  final AppChipSize size;         // small, medium
}

/// Badge for status, counts, indicators
class AppBadge extends StatelessWidget {
  final String? label;            // null = dot badge
  final IconData? icon;
  final Color color;              // AppColors.success/warning/error/info
  final AppBadgeSize size;        // small, medium, large
  final AppBadgeVariant variant;  // filled, outlined, soft
}
```

---

### Priority 2: Form Components

#### 2.1 AppTextField

```dart
/// Unified text field with all input states
class AppTextField extends StatelessWidget {
  // Value
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  
  // Labels
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? successText;
  
  // Visual
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  
  // Behavior
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  
  // State
  final bool isEnabled;
  final bool isReadOnly;
  final bool isRequired;
  
  // Validation
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
}
```

---

#### 2.2 AppDropdown

```dart
/// Dropdown selector with search support
class AppDropdown<T> extends StatelessWidget {
  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  
  final String? label;
  final String? hint;
  final String? errorText;
  
  final bool isEnabled;
  final bool isSearchable;
  final bool isMultiSelect;
  final Widget Function(T)? itemBuilder;
}

class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool isEnabled;
}
```

---

#### 2.3 AppSlider & AppRangeSlider

```dart
/// Slider with value display and custom styling
class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  
  final String? label;
  final String Function(double)? valueFormatter;
  final bool showValue;
  final bool showMinMax;
}
```

---

#### 2.4 AppToggle / AppSwitch

```dart
/// Toggle switch with optional label
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  
  final String? label;
  final String? description;
  final bool isEnabled;
  
  final AppToggleSize size;      // small, medium, large
  final AppToggleVariant variant; // switch, checkbox, radio
}
```

---

### Priority 3: Feedback Components

#### 3.1 AppSnackbar / AppToast

```dart
/// Show a snackbar notification
void showAppSnackbar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  AppSnackbarVariant variant,   // info, success, warning, error
  Duration duration,
  bool showCloseButton,
});

enum AppSnackbarVariant { info, success, warning, error }
```

---

#### 3.2 AppBanner

```dart
/// Dismissible banner for persistent messages
class AppBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final AppBannerVariant variant;  // info, success, warning, error
  final IconData? icon;
}
```

---

#### 3.3 AppDialog

```dart
/// Show a standardized dialog
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  List<AppDialogAction>? actions,
  bool barrierDismissible,
  AppDialogVariant variant,    // alert, confirm, form, fullscreen
});

class AppDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isPrimary;
}
```

---

#### 3.4 AppBottomSheet

```dart
/// Show a bottom sheet
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool isDismissible,
  bool enableDrag,
  double? initialHeight,
  double? maxHeight,
});
```

---

### Priority 4: Data Display

#### 4.1 AppAvatar

```dart
/// User/entity avatar with fallback
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final IconData? fallbackIcon;
  final AppAvatarSize size;      // xsmall, small, medium, large, xlarge
  final AppAvatarShape shape;    // circle, rounded, square
  final Color? backgroundColor;
  final Widget? badge;           // Online indicator, count badge, etc.
}

enum AppAvatarSize { 
  xsmall(24), small(32), medium(40), large(56), xlarge(80);
  final double diameter;
  const AppAvatarSize(this.diameter);
}
```

---

#### 4.2 AppProgressIndicator

```dart
/// Unified progress display
class AppProgressIndicator extends StatelessWidget {
  final double? value;           // null = indeterminate
  final AppProgressVariant variant;  // linear, circular, segmented
  final AppProgressSize size;    // small, medium, large
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final bool showPercentage;
}
```

---

#### 4.3 AppEmptyState (Enhanced)

Already exists, but should add more variants:

```dart
/// Extended empty state options
class AppEmptyState extends StatelessWidget {
  // Existing props...
  
  // New: Pre-built illustrations
  final AppEmptyStateIllustration? illustration;
  // noTanks, noData, noSearch, noConnection, error, maintenance
}
```

---

#### 4.4 AppTag

```dart
/// Simple tag/label component
class AppTag extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final AppTagSize size;          // small, medium
  final AppTagVariant variant;    // filled, outlined, soft
}
```

---

### Priority 5: Layout Components

#### 5.1 AppSection

```dart
/// Section with header and optional actions
class AppSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool collapsible;
  final bool initiallyExpanded;
}
```

---

#### 5.2 AppDivider

```dart
/// Divider with optional label
class AppDivider extends StatelessWidget {
  final String? label;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
}
```

---

#### 5.3 AppSpacing

```dart
/// Semantic spacing widgets
class AppGap extends StatelessWidget {
  final AppSpacingSize size;  // xs, sm, md, lg, xl, xxl
  final Axis axis;
}

// Usage:
// AppGap.sm()  // 8px vertical
// AppGap.md(axis: Axis.horizontal)  // 16px horizontal
```

---

## Component API Specifications

### Standard Props Pattern

All components should support these common patterns:

```dart
// Sizing
enum ComponentSize { small, medium, large }

// Variants (visual style)
enum ComponentVariant { primary, secondary, tertiary, ... }

// State
bool isEnabled = true;
bool isLoading = false;
bool isSelected = false;

// Accessibility
String? semanticLabel;
String? semanticHint;

// Testing
Key? key;
```

### State Management

Components should expose:
1. **Controlled mode:** Value + onChange callback
2. **Uncontrolled mode:** initialValue for internal state
3. **Form integration:** Works with Form/FormField widgets

---

## Implementation Priority

### Tier 1: Foundation (Week 1-2) — Highest ROI
| Component | Impact | Effort | Score |
|-----------|--------|--------|-------|
| AppButton | 🔴 High | 🟢 Low | ⭐⭐⭐⭐⭐ |
| AppCard | 🔴 High | 🟡 Med | ⭐⭐⭐⭐⭐ |
| AppListTile | 🔴 High | 🟡 Med | ⭐⭐⭐⭐ |
| AppChip/AppBadge | 🟡 Med | 🟢 Low | ⭐⭐⭐⭐ |
| AppTextField | 🔴 High | 🟡 Med | ⭐⭐⭐⭐ |

### Tier 2: Forms (Week 2-3)
| Component | Impact | Effort | Score |
|-----------|--------|--------|-------|
| AppDropdown | 🟡 Med | 🟡 Med | ⭐⭐⭐ |
| AppToggle | 🟡 Med | 🟢 Low | ⭐⭐⭐⭐ |
| AppSlider | 🟢 Low | 🟢 Low | ⭐⭐⭐ |

### Tier 3: Feedback (Week 3-4)
| Component | Impact | Effort | Score |
|-----------|--------|--------|-------|
| AppSnackbar | 🟡 Med | 🟢 Low | ⭐⭐⭐⭐ |
| AppDialog | 🟡 Med | 🟡 Med | ⭐⭐⭐ |
| AppBanner | 🟢 Low | 🟢 Low | ⭐⭐⭐ |
| AppBottomSheet | 🟡 Med | 🟡 Med | ⭐⭐⭐ |

### Tier 4: Data Display (Week 4-5)
| Component | Impact | Effort | Score |
|-----------|--------|--------|-------|
| AppAvatar | 🟡 Med | 🟢 Low | ⭐⭐⭐⭐ |
| AppProgressIndicator | 🟡 Med | 🟡 Med | ⭐⭐⭐ |
| AppTag | 🟢 Low | 🟢 Low | ⭐⭐⭐ |

### Tier 5: Layout (Week 5-6)
| Component | Impact | Effort | Score |
|-----------|--------|--------|-------|
| AppSection | 🟡 Med | 🟢 Low | ⭐⭐⭐ |
| AppGap | 🟢 Low | 🟢 Low | ⭐⭐⭐⭐ |
| AppDivider | 🟢 Low | 🟢 Low | ⭐⭐ |

---

## Naming Conventions

### File Naming
```
lib/widgets/
├── core/
│   ├── app_button.dart
│   ├── app_card.dart
│   └── app_list_tile.dart
├── forms/
│   ├── app_text_field.dart
│   └── app_dropdown.dart
├── feedback/
│   ├── app_snackbar.dart
│   └── app_dialog.dart
└── data_display/
    ├── app_avatar.dart
    └── app_badge.dart
```

### Class Naming
- Prefix with `App` for core components: `AppButton`, `AppCard`
- Suffix with variant for specialized versions: `AppButtonDestructive`, `AppCardGlass`
- Helper functions: `showAppSnackbar()`, `showAppDialog()`

### Props Naming
- Boolean: `isEnabled`, `isLoading`, `isSelected` (not `enabled`, `loading`)
- Callbacks: `onPressed`, `onChanged`, `onDismiss` (use `on` prefix)
- Size/Variant: Use enums, not strings
- Optional props: Use `?` and null for "not set"

---

## Directory Structure

### Proposed Organization

```
lib/
├── widgets/
│   ├── core/                    # Foundation components
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── app_list_tile.dart
│   │   ├── app_chip.dart
│   │   ├── app_badge.dart
│   │   └── core.dart            # Barrel export
│   │
│   ├── forms/                   # Form components
│   │   ├── app_text_field.dart
│   │   ├── app_dropdown.dart
│   │   ├── app_slider.dart
│   │   ├── app_toggle.dart
│   │   └── forms.dart           # Barrel export
│   │
│   ├── feedback/                # Feedback components
│   │   ├── app_snackbar.dart
│   │   ├── app_dialog.dart
│   │   ├── app_banner.dart
│   │   ├── app_bottom_sheet.dart
│   │   └── feedback.dart        # Barrel export
│   │
│   ├── data_display/            # Data display components
│   │   ├── app_avatar.dart
│   │   ├── app_progress.dart
│   │   ├── app_tag.dart
│   │   └── data_display.dart    # Barrel export
│   │
│   ├── layout/                  # Layout components
│   │   ├── app_section.dart
│   │   ├── app_divider.dart
│   │   ├── app_gap.dart
│   │   └── layout.dart          # Barrel export
│   │
│   ├── states/                  # State displays (existing)
│   │   ├── empty_state.dart
│   │   ├── error_state.dart
│   │   ├── loading_state.dart
│   │   └── states.dart          # Barrel export
│   │
│   ├── skeletons/              # Skeleton loaders (existing)
│   │   └── skeleton_loader.dart
│   │
│   ├── gamification/           # Game mechanics (existing)
│   │   ├── xp_progress_bar.dart
│   │   ├── daily_goal_progress.dart
│   │   └── ...
│   │
│   ├── navigation/             # Navigation (existing)
│   │   ├── speed_dial_fab.dart
│   │   └── room_navigation.dart
│   │
│   └── widgets.dart            # Master barrel export
│
└── theme/
    ├── app_theme.dart          # Existing theme
    ├── app_colors.dart         # Could extract
    ├── app_typography.dart     # Could extract
    └── app_spacing.dart        # Could extract
```

### Barrel Exports

```dart
// lib/widgets/widgets.dart
export 'core/core.dart';
export 'forms/forms.dart';
export 'feedback/feedback.dart';
export 'data_display/data_display.dart';
export 'layout/layout.dart';
export 'states/states.dart';
export 'skeletons/skeleton_loader.dart';
export 'gamification/xp_progress_bar.dart';
// ... etc
```

---

## Usage Guidelines

### When to Use Each Component

| Need | Component |
|------|-----------|
| Primary action | `AppButton(variant: .primary)` |
| Secondary action | `AppButton(variant: .secondary)` |
| Destructive action | `AppButton(variant: .destructive)` |
| Card with tap | `AppCard(onTap: ...)` |
| List of items | `AppListTile` |
| Filter selection | `AppChip` |
| Status indicator | `AppBadge` |
| Form input | `AppTextField` |
| Success message | `showAppSnackbar(variant: .success)` |
| Confirmation | `showAppDialog(variant: .confirm)` |

### Composition Example

```dart
// Before: Custom inline widget
class _ExpenseCard extends StatelessWidget { ... }  // 50 lines

// After: Composed from library
AppCard(
  variant: AppCardVariant.outlined,
  onTap: () => _showExpenseDetail(expense),
  child: AppListTile(
    title: expense.title,
    subtitle: expense.category,
    caption: expense.formattedDate,
    leading: AppAvatar(
      fallbackIcon: expense.categoryIcon,
      backgroundColor: expense.categoryColor,
      size: AppAvatarSize.small,
    ),
    trailing: AppBadge(
      label: expense.formattedAmount,
      variant: AppBadgeVariant.soft,
      color: AppColors.primary,
    ),
  ),
)
```

---

## Migration Strategy

### Phase 1: Create Core Components
1. Implement Tier 1 components (`AppButton`, `AppCard`, `AppListTile`)
2. Add to `widgets/core/` with full documentation
3. Create storybook/preview screen for testing

### Phase 2: Gradual Replacement
1. Start with new screens — use library components
2. Refactor high-traffic screens first (Home, Tank Detail)
3. Replace inline widgets one screen at a time
4. Delete inline widgets after migration

### Phase 3: Deprecate Inline Widgets
1. Mark old patterns as deprecated
2. Add lint rules to prevent new inline widgets
3. Complete migration of all screens

### Phase 4: Documentation
1. Create widget catalog screen in app (dev mode)
2. Generate API documentation
3. Add usage examples to each component file

---

## Success Metrics

- [ ] **Consistency:** 90%+ of UI uses library components
- [ ] **Deduplication:** Reduce inline widgets from 339 to <50
- [ ] **Accessibility:** All components WCAG AA compliant
- [ ] **Documentation:** 100% of components have usage docs
- [ ] **Test Coverage:** 80%+ widget test coverage

---

## Appendix: Code Examples

### AppButton Implementation Sketch

```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    
    final button = _buildButton(context, isEnabled);
    
    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      enabled: isEnabled,
      child: isFullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled) {
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getForegroundColor(),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _getIconSize()),
          const SizedBox(width: 8),
        ],
        Text(label, style: textStyle),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _getIconSize()),
        ],
      ],
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.textPrimary,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: padding,
            foregroundColor: AppColors.primary,
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            padding: padding,
            foregroundColor: AppColors.primary,
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall;
      case AppButtonSize.medium:
        return AppTypography.labelMedium;
      case AppButtonSize.large:
        return AppTypography.labelLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 22;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}
```

---

## Next Steps

1. **Review this spec** with stakeholders
2. **Prototype Tier 1** components
3. **Create widget catalog** for visual testing
4. **Begin migration** of high-impact screens
5. **Iterate** based on real usage

---

*This document is a living specification. Update as components are implemented and patterns evolve.*
