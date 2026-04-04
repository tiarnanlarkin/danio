import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_list_tile.dart';

/// A drawer/navigation list item wrapping [NavListTile] with optional icon badge.
///
/// Designed for use in app drawers, settings lists, and navigation menus.
///
/// Example:
/// ```dart
/// DrawerListItem(
///   icon: Icons.settings,
///   title: 'Settings',
///   badgeCount: 3,
///   onTap: () => openSettings(),
/// )
/// ```
class DrawerListItem extends StatelessWidget {
  /// Leading icon
  final IconData icon;

  /// Item title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Icon color (defaults to theme secondary)
  final Color? iconColor;

  /// Badge count (shown as a small numbered badge on the icon)
  /// Set to 0 or null to hide.
  final int? badgeCount;

  /// Whether to show a dot badge instead of count
  final bool showDotBadge;

  /// Tap handler
  final VoidCallback onTap;

  const DrawerListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.badgeCount,
    this.showDotBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? badge;
    if (showDotBadge) {
      badge = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      );
    } else if (badgeCount != null && badgeCount! > 0) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs2, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Text(
          badgeCount! > 99 ? '99+' : '$badgeCount',
          style: AppTypography.labelSmall.copyWith(color: AppColors.onError),
        ),
      );
    }

    return NavListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      badge: badge,
      onTap: onTap,
    );
  }
}
