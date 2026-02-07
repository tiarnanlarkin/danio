# Standard Widget Templates

These widgets should be created for consistency across the app.

---

## 1. Empty State Widget

**File:** `lib/widgets/empty_state.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard empty state for lists and collections
/// 
/// Usage:
/// ```dart
/// if (items.isEmpty) {
///   return AppEmptyState(
///     icon: Icons.pets,
///     title: 'No livestock yet',
///     subtitle: 'Add fish, shrimp, or snails to get started',
///     action: ElevatedButton(...),
///   );
/// }
/// ```
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### Example Usage:

```dart
// In livestock_screen.dart
if (livestock.isEmpty) {
  return AppEmptyState(
    icon: Icons.set_meal,
    title: 'No livestock yet',
    subtitle: 'Add fish, shrimp, or snails',
    action: ElevatedButton.icon(
      onPressed: () => _showAddDialog(context, ref),
      icon: Icon(Icons.add),
      label: Text('Add Livestock'),
    ),
  );
}
```

---

## 2. Error State Widget

**File:** `lib/widgets/error_state.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard error display with retry option
/// 
/// Usage:
/// ```dart
/// if (error != null) {
///   return AppErrorState(
///     message: 'Failed to load data',
///     onRetry: () => ref.refresh(provider),
///   );
/// }
/// ```
class AppErrorState extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorState({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                details!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Example Usage:

```dart
// In any screen with error handling
return tankAsync.when(
  loading: () => AppLoadingIndicator(),
  error: (err, stack) => AppErrorState(
    message: 'Failed to load tank',
    details: err.toString(),
    onRetry: () => ref.invalidate(tankProvider(tankId)),
  ),
  data: (tank) => ...,
);
```

---

## 3. Loading Indicator Widget

**File:** `lib/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard loading indicator
/// 
/// Usage:
/// ```dart
/// if (isLoading) {
///   return AppLoadingIndicator(message: 'Loading tanks...');
/// }
/// ```
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator for buttons
class AppLoadingButton extends StatelessWidget {
  final Color? color;

  const AppLoadingButton({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(color ?? Colors.white),
      ),
    );
  }
}
```

### Example Usage:

```dart
// Full screen loading
if (isLoading) {
  return Scaffold(
    body: AppLoadingIndicator(message: 'Loading tanks...'),
  );
}

// Button loading state
ElevatedButton(
  onPressed: isCreating ? null : _createTank,
  child: isCreating 
    ? AppLoadingButton() 
    : Text('Create Tank'),
)
```

---

## 4. Status Badge Widget

**File:** `lib/widgets/app_badge.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

/// Standard status badge
/// 
/// Usage:
/// ```dart
/// AppBadge(
///   type: BadgeType.warning,
///   label: '2 overdue',
///   icon: Icons.warning_amber,
/// )
/// ```
class AppBadge extends StatelessWidget {
  final BadgeType type;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    required this.type,
    required this.label,
    this.icon,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.success.withOpacity(0.1);
      case BadgeType.warning:
        return AppColors.warning.withOpacity(0.1);
      case BadgeType.error:
        return AppColors.error.withOpacity(0.1);
      case BadgeType.info:
        return AppColors.info.withOpacity(0.1);
      case BadgeType.neutral:
        return AppColors.surfaceVariant;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.error:
        return AppColors.error;
      case BadgeType.info:
        return AppColors.info;
      case BadgeType.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _foregroundColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: _foregroundColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: badge,
      );
    }

    return badge;
  }
}
```

### Example Usage:

```dart
// In tank_card.dart
Wrap(
  spacing: 8,
  children: [
    AppBadge(
      type: BadgeType.warning,
      icon: Icons.warning_amber,
      label: '2 overdue',
    ),
    AppBadge(
      type: BadgeType.info,
      icon: Icons.today,
      label: '3 today',
    ),
  ],
)
```

---

## 5. Card Variants Helper

**File:** `lib/widgets/app_cards.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard card variants for consistent styling
class AppCards {
  /// Standard white/dark card
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.largeRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }

  /// Info card (blue background)
  static Widget info({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.info.withOpacity(0.1),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }

  /// Warning card (amber background)
  static Widget warning({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }

  /// Error card (red background)
  static Widget error({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }

  /// Success card (green background)
  static Widget success({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.success.withOpacity(0.1),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }

  /// Glass morphism card (already exists as GlassCard)
  static Widget glass({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return GlassCard(
      padding: padding,
      child: child,
    );
  }
}
```

### Example Usage:

```dart
// Replace this:
Card(
  color: AppColors.info.withOpacity(0.1),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Info message'),
  ),
)

// With this:
AppCards.info(
  child: Text('Info message'),
)
```

---

## Implementation Priority

1. **Week 1:** AppEmptyState, AppErrorState, AppLoadingIndicator
2. **Week 2:** AppBadge, AppCards
3. **Refactor existing screens** to use new widgets

---

## Testing Template

```dart
// test/widgets/empty_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/widgets/empty_state.dart';

void main() {
  testWidgets('AppEmptyState displays title and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.pets,
            title: 'No items',
            subtitle: 'Add some items',
          ),
        ),
      ),
    );

    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Add some items'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });
}
```

---

## Migration Checklist

After creating these widgets:

- [ ] Replace ad-hoc empty states with AppEmptyState
- [ ] Replace ad-hoc error displays with AppErrorState  
- [ ] Replace CircularProgressIndicator with AppLoadingIndicator
- [ ] Replace custom badges with AppBadge
- [ ] Use AppCards helpers for consistent card styling
- [ ] Update documentation with widget usage
- [ ] Add accessibility tests for all widgets
- [ ] Verify semantic labels are present

---

Total Estimated Time: **2-3 days** (including refactoring existing code)  
Impact: **High** (massive consistency improvement)  
Maintenance: **Low** (centralized styling, easy updates)
