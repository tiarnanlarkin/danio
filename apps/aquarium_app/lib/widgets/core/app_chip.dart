import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Visual variants for chips
enum AppChipVariant {
  /// Filled background
  filled,
  
  /// Outlined with border
  outlined,
  
  /// Tonal (subtle filled)
  tonal,
}

/// Size variants for chips
enum AppChipSize {
  /// Small: 32dp height (compact visual, 48dp touch target)
  small,
  
  /// Medium: 36dp height (default, 48dp touch target)
  medium,
  
  /// Large: 40dp height (48dp touch target)
  large,
}

/// A unified chip component for tags, filters, and selections.
/// 
/// Consolidates 30+ chip/badge variants into a single component.
/// Supports selection, deletion, and various visual styles.
/// 
/// Example:
/// ```dart
/// AppChip(
///   label: 'Freshwater',
///   isSelected: true,
///   onTap: () => toggleFilter(),
/// )
/// ```
class AppChip extends StatelessWidget {
  /// Label text
  final String label;
  
  /// Visual variant
  final AppChipVariant variant;
  
  /// Size
  final AppChipSize size;
  
  /// Optional leading icon
  final IconData? icon;
  
  /// Custom color (affects background/border based on variant)
  final Color? color;
  
  /// Whether the chip is selected
  final bool isSelected;
  
  /// Whether the chip is disabled
  final bool isDisabled;
  
  /// Called when chip is tapped
  final VoidCallback? onTap;
  
  /// Called when delete icon is tapped (shows delete icon when non-null)
  final VoidCallback? onDeleted;
  
  /// Custom delete icon
  final IconData? deleteIcon;
  
  /// Whether to show a checkmark when selected
  final bool showCheckmark;
  
  /// Semantic label for accessibility
  final String? semanticsLabel;

  const AppChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.filled,
    this.size = AppChipSize.medium,
    this.icon,
    this.color,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
    this.onDeleted,
    this.deleteIcon,
    this.showCheckmark = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;
    
    final isInteractive = onTap != null && !isDisabled;
    
    // Material Design 3: Ensure minimum 48dp touch target
    // Visual height can be smaller, but touch area must be 48dp
    final visualHeight = _getHeight();
    final minTouchTarget = AppTouchTargets.minimum;
    
    return Semantics(
      button: isInteractive,
      selected: isSelected,
      enabled: !isDisabled,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        onTap: isInteractive ? () {
          HapticFeedback.selectionClick();
          onTap!();
        } : null,
        child: Container(
          // Ensure minimum touch target height
          constraints: BoxConstraints(
            minHeight: minTouchTarget,
          ),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: AppDurations.short,
            height: visualHeight,
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: _getBackgroundColor(effectiveColor, isDark),
              borderRadius: BorderRadius.circular(visualHeight / 2),
              border: _getBorder(effectiveColor, isDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCheckmark && isSelected) ...[
                  Icon(
                    Icons.check,
                    size: _getIconSize(),
                    color: _getForegroundColor(effectiveColor, isDark),
                  ),
                  SizedBox(width: AppSpacing.xs),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: _getIconSize(),
                    color: _getForegroundColor(effectiveColor, isDark),
                  ),
                  SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: _getTextStyle(effectiveColor, isDark),
                ),
                if (onDeleted != null) ...[
                  SizedBox(width: AppSpacing.xs),
                  Semantics(
                    label: 'Delete $label',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onDeleted!();
                      },
                      child: Icon(
                        deleteIcon ?? Icons.close,
                        size: _getIconSize(),
                        color: _getForegroundColor(effectiveColor, isDark),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    // Visual heights - touch target is enforced by wrapper
    switch (size) {
      case AppChipSize.small:
        return 32; // Increased from 24dp for better readability
      case AppChipSize.medium:
        return 36; // Increased from 32dp
      case AppChipSize.large:
        return 40; // Unchanged
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppChipSize.small:
        return EdgeInsets.symmetric(horizontal: AppSpacing.sm);
      case AppChipSize.medium:
        return EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case AppChipSize.large:
        return EdgeInsets.symmetric(horizontal: AppSpacing.lg);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppChipSize.small:
        return AppIconSizes.xs;
      case AppChipSize.medium:
        return AppIconSizes.sm;
      case AppChipSize.large:
        return AppIconSizes.md;
    }
  }

  Color _getBackgroundColor(Color baseColor, bool isDark) {
    if (isDisabled) {
      return isDark ? AppOverlays.white10 : AppOverlays.black10;
    }
    
    switch (variant) {
      case AppChipVariant.filled:
        return isSelected ? baseColor : baseColor.withAlpha(38);
      case AppChipVariant.outlined:
        return isSelected ? baseColor.withAlpha(38) : Colors.transparent;
      case AppChipVariant.tonal:
        return isSelected ? baseColor.withAlpha(64) : baseColor.withAlpha(26);
    }
  }

  Border? _getBorder(Color baseColor, bool isDark) {
    if (variant != AppChipVariant.outlined) return null;
    
    if (isDisabled) {
      return Border.all(
        color: isDark ? AppOverlays.white20 : AppOverlays.black20,
        width: 1,
      );
    }
    
    return Border.all(
      color: isSelected ? baseColor : baseColor.withAlpha(128),
      width: isSelected ? 1.5 : 1,
    );
  }

  Color _getForegroundColor(Color baseColor, bool isDark) {
    if (isDisabled) {
      return isDark ? AppOverlays.white30 : AppOverlays.black30;
    }
    
    switch (variant) {
      case AppChipVariant.filled:
        return isSelected ? Colors.white : baseColor;
      case AppChipVariant.outlined:
      case AppChipVariant.tonal:
        return baseColor;
    }
  }

  TextStyle _getTextStyle(Color baseColor, bool isDark) {
    final color = _getForegroundColor(baseColor, isDark);
    
    switch (size) {
      case AppChipSize.small:
        return AppTypography.labelSmall.copyWith(color: color);
      case AppChipSize.medium:
        return AppTypography.labelMedium.copyWith(color: color);
      case AppChipSize.large:
        return AppTypography.labelLarge.copyWith(color: color);
    }
  }
}

/// A badge component for status indicators and counts.
class AppBadge extends StatelessWidget {
  /// Badge content (text or number)
  final String? label;
  
  /// Count to display (alternative to label)
  final int? count;
  
  /// Badge color
  final Color? color;
  
  /// Whether this is a dot badge (no content)
  final bool isDot;
  
  /// Size (affects padding and font)
  final AppChipSize size;
  
  /// Whether to show pulse animation (for notifications)
  final bool pulse;

  const AppBadge({
    super.key,
    this.label,
    this.count,
    this.color,
    this.isDot = false,
    this.size = AppChipSize.small,
    this.pulse = false,
  });

  const AppBadge.dot({
    super.key,
    this.color,
    this.pulse = false,
  }) : label = null,
       count = null,
       isDot = true,
       size = AppChipSize.small;

  const AppBadge.count({
    super.key,
    required int this.count,
    this.color,
    this.size = AppChipSize.small,
  }) : label = null,
       isDot = false,
       pulse = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.error;
    
    if (isDot) {
      return _buildDot(effectiveColor);
    }
    
    final displayText = label ?? (count != null ? (count! > 99 ? '99+' : count.toString()) : '');
    
    return Container(
      constraints: BoxConstraints(
        minWidth: _getMinWidth(),
        minHeight: _getHeight(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: displayText.length > 1 ? AppSpacing.sm : 0,
      ),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(_getHeight() / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        displayText,
        style: _getTextStyle(),
      ),
    );
  }

  Widget _buildDot(Color effectiveColor) {
    final dotSize = size == AppChipSize.small ? 8.0 : 
                    size == AppChipSize.medium ? 10.0 : 12.0;
    
    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: effectiveColor,
        shape: BoxShape.circle,
      ),
    );
    
    if (pulse) {
      dot = _PulsingDot(color: effectiveColor, size: dotSize);
    }
    
    return dot;
  }

  double _getMinWidth() {
    switch (size) {
      case AppChipSize.small:
        return 18;
      case AppChipSize.medium:
        return 22;
      case AppChipSize.large:
        return 26;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppChipSize.small:
        return 18;
      case AppChipSize.medium:
        return 22;
      case AppChipSize.large:
        return 26;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppChipSize.small:
        return AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        );
      case AppChipSize.medium:
        return AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
      case AppChipSize.large:
        return AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
    }
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.celebration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            Container(
              width: widget.size + (8 * _controller.value),
              height: widget.size + (8 * _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withAlpha((0.3 * (1 - _controller.value * 255).round())),
              ),
            ),
            // Core dot
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A group of filter chips for multi-select scenarios.
class AppChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final bool singleSelect;
  final AppChipVariant variant;
  final AppChipSize size;
  final double spacing;
  final bool wrap;

  const AppChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.singleSelect = false,
    this.variant = AppChipVariant.filled,
    this.size = AppChipSize.medium,
    this.spacing = 8,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final chips = options.map((option) => AppChip(
      label: option,
      variant: variant,
      size: size,
      isSelected: selected.contains(option),
      showCheckmark: !singleSelect,
      onTap: () => onToggle(option),
    )).toList();

    if (wrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: chips,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            chips[i],
            if (i < chips.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}
