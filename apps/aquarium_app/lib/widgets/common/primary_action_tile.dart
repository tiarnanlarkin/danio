import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// A prominent, tappable action tile for primary user actions.
///
/// Renders as a rounded card row: leading icon container → title + subtitle →
/// optional badge → trailing chevron (or custom widget).
///
/// Compared to plain [ListTile], this widget uses:
/// - [AppSpacing], [AppRadius], [AppColors] tokens throughout
/// - Optional coloured icon background for visual hierarchy
/// - Scale animation on tap (0.98×) for satisfying feedback
/// - [Semantics] role `button`
///
/// Example:
/// ```dart
/// PrimaryActionTile(
///   icon: Icons.water_drop,
///   iconColor: AppColors.info,
///   title: 'Log Water Change',
///   subtitle: 'Last changed 6 days ago',
///   onTap: () => logWaterChange(),
/// )
/// ```
class PrimaryActionTile extends StatefulWidget {
  /// Icon displayed in the coloured leading container.
  final IconData icon;

  /// Colour of the icon. Defaults to [AppColors.primary].
  final Color? iconColor;

  /// Background colour of the icon container.
  /// Defaults to [iconColor] at 15% opacity.
  final Color? iconBackgroundColor;

  /// Primary text (required).
  final String title;

  /// Secondary text beneath the title.
  final String? subtitle;

  /// Small badge text (e.g. count, status) shown before the trailing widget.
  final String? badge;

  /// Colour of the badge pill background. Defaults to [AppColors.primary].
  final Color? badgeColor;

  /// Custom trailing widget. Defaults to a chevron icon.
  final Widget? trailing;

  /// Hides the chevron when [trailing] is null. Defaults to true.
  final bool showChevron;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Semantic label for accessibility. Defaults to [title].
  final String? semanticsLabel;

  /// Whether to provide haptic feedback on tap. Defaults to true.
  final bool enableHaptics;

  /// External margin. Defaults to none.
  final EdgeInsets? margin;

  const PrimaryActionTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.enableHaptics = true,
    this.margin,
  });

  @override
  State<PrimaryActionTile> createState() => _PrimaryActionTileState();
}

class _PrimaryActionTileState extends State<PrimaryActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  void _handleTap() {
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIconColor = widget.iconColor ?? AppColors.primary;
    // Build icon background at 15% opacity using pre-constructed RGBA.
    final iconBg = widget.iconBackgroundColor ??
        Color.fromRGBO(
          effectiveIconColor.red,
          effectiveIconColor.green,
          effectiveIconColor.blue,
          0.15,
        );

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final chevronColor =
        isDark ? AppColors.textHintDark : AppColors.textHint;

    Widget content = Container(
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          // ── Icon container ─────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.r12Radius,
            ),
            child: Icon(
              widget.icon,
              color: effectiveIconColor,
              size: AppIconSizes.md,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Title / subtitle ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.titleSmall.copyWith(color: titleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.subtitle!,
                    style: AppTypography.bodySmall.copyWith(color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Badge ──────────────────────────────────────────────────────
          if (widget.badge != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? AppColors.primary,
                borderRadius: AppRadius.pillRadius,
              ),
              child: Text(
                widget.badge!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],

          // ── Trailing / chevron ─────────────────────────────────────────
          if (widget.trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            widget.trailing!,
          ] else if (widget.showChevron && _isInteractive) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: chevronColor, size: AppIconSizes.md),
          ],
        ],
      ),
    );

    if (_isInteractive) {
      content = Semantics(
        button: true,
        label: widget.semanticsLabel ?? widget.title,
        hint: widget.subtitle,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: _handleTap,
            onLongPress: widget.onLongPress,
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
