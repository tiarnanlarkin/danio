import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// A unified list tile component for all list contexts.
/// 
/// Consolidates 35+ inline list item variants into a single, flexible component.
/// Provides consistent spacing, accessibility, and optional swipe actions.
/// 
/// Example:
/// ```dart
/// AppListTile(
///   title: 'Item Name',
///   subtitle: 'Description',
///   leading: Icon(Icons.star),
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => showDetails(),
/// )
/// ```
class AppListTile extends StatefulWidget {
  /// Primary text
  final String title;
  
  /// Secondary text (optional)
  final String? subtitle;
  
  /// Tertiary text or metadata (optional)
  final String? meta;
  
  /// Leading widget (icon, avatar, image)
  final Widget? leading;
  
  /// Trailing widget (icon, badge, switch)
  final Widget? trailing;
  
  /// Called when tile is tapped
  final VoidCallback? onTap;
  
  /// Called when tile is long-pressed
  final VoidCallback? onLongPress;
  
  /// Whether the tile is in a selected state
  final bool isSelected;
  
  /// Whether the tile is disabled
  final bool isDisabled;
  
  /// Whether to use destructive styling (for delete actions)
  final bool isDestructive;
  
  /// Minimum height (defaults to 56dp for accessibility)
  final double? minHeight;
  
  /// Custom padding
  final EdgeInsets? padding;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Selected background color
  final Color? selectedColor;
  
  /// Content padding between elements
  final double? contentSpacing;
  
  /// Whether to show a divider below
  final bool showDivider;
  
  /// Dense mode (reduced vertical padding)
  final bool dense;
  
  /// Enable haptic feedback
  final bool enableHaptics;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.meta,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isDisabled = false,
    this.isDestructive = false,
    this.minHeight,
    this.padding,
    this.backgroundColor,
    this.selectedColor,
    this.contentSpacing,
    this.showDivider = false,
    this.dense = false,
    this.enableHaptics = true,
  });

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile> {
  bool _isPressed = false;

  bool get _isInteractive => 
      (widget.onTap != null || widget.onLongPress != null) && !widget.isDisabled;

  void _handleTapDown(TapDownDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (_isInteractive && widget.onTap != null) {
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (_isInteractive && widget.onLongPress != null) {
      if (widget.enableHaptics) HapticFeedback.mediumImpact();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectivePadding = widget.padding ?? EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: widget.dense ? AppSpacing.sm : AppSpacing.md,
    );
    
    final spacing = widget.contentSpacing ?? AppSpacing.md;
    
    // Determine colors
    Color? bgColor;
    if (widget.isSelected) {
      bgColor = widget.selectedColor ?? AppOverlays.primary10;
    } else if (_isPressed && _isInteractive) {
      bgColor = isDark ? AppOverlays.white5 : AppOverlays.black5;
    } else {
      bgColor = widget.backgroundColor;
    }

    final titleColor = widget.isDisabled
        ? (isDark ? AppColors.textHintDark : AppColors.textHint)
        : widget.isDestructive
            ? AppColors.error
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    final subtitleColor = widget.isDisabled
        ? (isDark ? AppColors.textHintDark : AppColors.textHint).withAlpha(153)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    Widget tile = Container(
      constraints: BoxConstraints(minHeight: widget.minHeight ?? 56),
      color: bgColor,
      padding: effectivePadding,
      child: Row(
        children: [
          if (widget.leading != null) ...[
            _buildLeading(isDark),
            SizedBox(width: spacing),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: titleColor,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.subtitle!,
                    style: AppTypography.bodySmall.copyWith(color: subtitleColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.meta != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.meta!,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            SizedBox(width: spacing),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (_isInteractive) {
      tile = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        behavior: HitTestBehavior.opaque,
        child: tile,
      );
    }

    tile = Semantics(
      button: _isInteractive,
      selected: widget.isSelected,
      enabled: !widget.isDisabled,
      label: widget.title,
      hint: widget.subtitle,
      child: tile,
    );

    if (widget.showDivider) {
      tile = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          Divider(
            height: 1,
            indent: widget.leading != null ? spacing + 40 : 0,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ],
      );
    }

    return tile;
  }

  Widget _buildLeading(bool isDark) {
    if (widget.leading == null) return const SizedBox.shrink();
    
    // Apply consistent styling to icon widgets
    if (widget.leading is Icon) {
      final icon = widget.leading as Icon;
      return Icon(
        icon.icon,
        size: icon.size ?? AppIconSizes.md,
        color: widget.isDisabled
            ? (isDark ? AppColors.textHintDark : AppColors.textHint)
            : widget.isDestructive
                ? AppColors.error
                : (icon.color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
      );
    }
    
    return widget.leading!;
  }
}

/// A grouped list section with optional header and footer.
class AppListSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final bool showDividers;
  final EdgeInsets? margin;
  final bool isCard;

  const AppListSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.showDividers = true,
    this.margin,
    this.isCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
              child: Text(
                header!.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          if (isCard)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: AppRadius.mediumRadius,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildChildren(isDark),
            )
          else
            _buildChildren(isDark),
          if (footer != null) ...[
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.xs, top: AppSpacing.sm),
              child: Text(
                footer!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChildren(bool isDark) {
    if (!showDividers) {
      return Column(children: children);
    }
    
    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            Divider(
              height: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
        ],
      ],
    );
  }
}

/// A simple navigation list tile with chevron.
class NavListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? badge;

  const NavListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.iconColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      leading: icon != null ? Icon(icon, color: iconColor) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            badge!,
            SizedBox(width: AppSpacing.sm),
          ],
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textHintDark
                : AppColors.textHint,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
