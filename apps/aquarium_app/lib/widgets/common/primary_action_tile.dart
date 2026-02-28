import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_card.dart';

/// A card-based action tile with icon, title, subtitle, and trailing action.
///
/// Combines [AppCard] with a Row layout for common list-action patterns
/// (e.g. settings rows, feature tiles, dashboard actions).
///
/// Example:
/// ```dart
/// PrimaryActionTile(
///   icon: Icons.water_drop,
///   title: 'Water Change',
///   subtitle: 'Last done 3 days ago',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => doWaterChange(),
/// )
/// ```
class PrimaryActionTile extends StatelessWidget {
  /// Leading icon
  final IconData icon;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Icon background color (defaults to primary at 10%)
  final Color? iconBackgroundColor;

  /// Primary text
  final String title;

  /// Secondary text (optional)
  final String? subtitle;

  /// Trailing widget (e.g. chevron, switch, badge)
  final Widget? trailing;

  /// Tap handler
  final VoidCallback? onTap;

  const PrimaryActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final effectiveIconColor = iconColor ?? primaryColor;

    final semanticLabel = subtitle != null ? '$title\n$subtitle' : title;

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: AppCard(
      variant: AppCardVariant.filled,
      padding: AppCardPadding.standard,
      onTap: onTap,

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? effectiveIconColor.withAlpha(26), // ~10%
              borderRadius: BorderRadius.circular(AppRadius.md2),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: AppIconSizes.md,
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153), // ~60%
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    ),
    );
  }
}
