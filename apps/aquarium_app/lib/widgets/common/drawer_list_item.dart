import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// A navigation item for use inside a [Drawer].
///
/// Consistent layout: leading icon → label → optional badge count.
/// Highlights the selected item with the app primary colour.
///
/// Tokens used:
/// - [AppTypography.body] / [AppTypography.label] for text
/// - [AppSpacing] for padding
/// - [AppColors.primary] / [AppColors.primaryAlpha15] for selection state
/// - [AppRadius.mediumRadius] for selection pill
///
/// Accessibility:
/// - Wrapped in [Semantics] with `button: true` and `selected` state
/// - Icon colour changes to communicate selection visually and semantically
///
/// Example:
/// ```dart
/// DrawerListItem(
///   icon: Icons.water,
///   label: 'My Tanks',
///   isSelected: currentRoute == '/tanks',
///   badge: pendingAlertsCount,
///   onTap: () => navigateTo('/tanks'),
/// )
/// ```
class DrawerListItem extends StatelessWidget {
  /// Leading icon.
  final IconData icon;

  /// Label text.
  final String label;

  /// Whether this item represents the current route/page.
  final bool isSelected;

  /// Optional numeric badge (e.g. unread count). Hidden when 0 or null.
  final int? badge;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  /// Custom icon colour. When null, uses [AppColors.primary] (selected) or
  /// [AppColors.textSecondary] (unselected).
  final Color? iconColor;

  /// Custom accessibility label. Defaults to [label].
  final String? semanticsLabel;

  const DrawerListItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.badge,
    this.onTap,
    this.iconColor,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIconColor = iconColor ??
        (isSelected
            ? AppColors.primary
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary));

    final labelColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    final bgColor = isSelected
        ? (isDark ? AppColors.primaryAlpha15 : AppColors.primaryAlpha10)
        : Colors.transparent;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel ?? label,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Material(
          color: bgColor,
          borderRadius: AppRadius.mediumRadius,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
            borderRadius: AppRadius.mediumRadius,
            child: Container(
              constraints: BoxConstraints(
                minHeight: AppTouchTargets.minimum,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // ── Icon ───────────────────────────────────────────────
                  Icon(
                    icon,
                    size: AppIconSizes.md,
                    color: effectiveIconColor,
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // ── Label ──────────────────────────────────────────────
                  Expanded(
                    child: Text(
                      label,
                      style: (isSelected
                              ? AppTypography.label
                              : AppTypography.body)
                          .copyWith(color: labelColor),
                    ),
                  ),

                  // ── Badge ──────────────────────────────────────────────
                  if (badge != null && badge! > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        badge! > 99 ? '99+' : badge.toString(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onError,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
