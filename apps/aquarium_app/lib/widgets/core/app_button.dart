import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Button variants for different use cases
enum AppButtonVariant {
  /// Primary action - filled with primary color
  primary,
  
  /// Secondary action - outlined style
  secondary,
  
  /// Tertiary/text-only action
  text,
  
  /// Destructive action (delete, remove)
  destructive,
  
  /// Ghost button - minimal styling
  ghost,
}

/// Button sizes
enum AppButtonSize {
  /// Small: 48dp height (Material Design 3 minimum)
  small,
  
  /// Medium: 48dp height (default, same as small for consistency)
  medium,
  
  /// Large: 56dp height (tablet/prominent actions)
  large,
}

/// A unified button component with consistent styling, accessibility, and haptics.
/// 
/// Replaces direct usage of ElevatedButton, TextButton, OutlinedButton
/// with app-specific styling and behavior.
/// 
/// Example:
/// ```dart
/// AppButton(
///   label: 'Save',
///   onPressed: () => save(),
///   variant: AppButtonVariant.primary,
/// )
/// ```
class AppButton extends StatefulWidget {
  /// Button label text
  final String label;
  
  /// Called when button is pressed. Null disables the button.
  final VoidCallback? onPressed;
  
  /// Visual variant of the button
  final AppButtonVariant variant;
  
  /// Size of the button
  final AppButtonSize size;
  
  /// Optional icon before the label
  final IconData? leadingIcon;
  
  /// Optional icon after the label
  final IconData? trailingIcon;
  
  /// Shows loading spinner and disables interaction
  final bool isLoading;
  
  /// Expands button to full width of parent
  final bool isFullWidth;
  
  /// Custom semantic label for accessibility
  final String? semanticsLabel;
  
  /// Whether to provide haptic feedback on press
  final bool enableHaptics;

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
    this.enableHaptics = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    if (_isEnabled) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.semanticsLabel ?? widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppDurations.short,
            height: _getHeight(),
            constraints: BoxConstraints(
              minWidth: widget.isFullWidth ? double.infinity : _getMinWidth(),
            ),
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: AppRadius.smallRadius,
              border: _getBorder(isDark),
              boxShadow: _getShadow(),
            ),
            child: Row(
              mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: _getIconSize(),
                    height: _getIconSize(),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_getForegroundColor(isDark)),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ] else if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: _getIconSize(),
                    color: _getForegroundColor(isDark),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  widget.label,
                  style: _getTextStyle(isDark),
                ),
                if (widget.trailingIcon != null && !widget.isLoading) ...[
                  SizedBox(width: AppSpacing.sm),
                  Icon(
                    widget.trailingIcon,
                    size: _getIconSize(),
                    color: _getForegroundColor(isDark),
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
    // Material Design 3 compliant heights
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTouchTargets.minimum; // 48dp
      case AppButtonSize.medium:
        return AppTouchTargets.minimum; // 48dp
      case AppButtonSize.large:
        return AppTouchTargets.medium; // 56dp
    }
  }

  double _getMinWidth() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 64;
      case AppButtonSize.medium:
        return 88;
      case AppButtonSize.large:
        return 120;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppIconSizes.xs;
      case AppButtonSize.medium:
        return AppIconSizes.sm;
      case AppButtonSize.large:
        return AppIconSizes.md;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    if (!_isEnabled) {
      return isDark ? AppOverlays.white10 : AppOverlays.black10;
    }
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return AppColors.error;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(bool isDark) {
    if (!_isEnabled) {
      return isDark ? AppOverlays.white30 : AppOverlays.black30;
    }
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.primary;
      case AppButtonVariant.text:
        return AppColors.primary;
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.ghost:
        return context.textPrimary;
    }
  }

  Border? _getBorder(bool isDark) {
    if (widget.variant == AppButtonVariant.secondary) {
      return Border.all(
        color: _isEnabled 
            ? AppColors.primary 
            : (isDark ? AppOverlays.white20 : AppOverlays.black20),
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow() {
    if (!_isEnabled) return null;
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return [
          BoxShadow(
            color: (widget.variant == AppButtonVariant.primary 
                ? AppColors.primary 
                : AppColors.error).withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return null;
    }
  }

  TextStyle _getTextStyle(bool isDark) {
    final color = _getForegroundColor(isDark);
    
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall.copyWith(color: color);
      case AppButtonSize.medium:
        return AppTypography.labelMedium.copyWith(color: color);
      case AppButtonSize.large:
        return AppTypography.labelLarge.copyWith(color: color);
    }
  }
}

/// Icon-only button variant for toolbar actions
/// Material Design 3 compliant: minimum 48x48dp touch targets
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final AppButtonSize size;
  final Color? color;
  final Color? backgroundColor;
  final bool enableHaptics;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticsLabel,
    this.size = AppButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = onPressed != null;
    
    // Material Design 3: minimum 48x48dp touch targets
    final double buttonSize = size == AppButtonSize.small ? AppTouchTargets.minimum : 
                              size == AppButtonSize.medium ? AppTouchTargets.minimum : 
                              AppTouchTargets.medium;
    final double iconSize = size == AppButtonSize.small ? AppIconSizes.sm : 
                            size == AppButtonSize.medium ? AppIconSizes.md : 
                            AppIconSizes.lg;

    // Require semantic label for icon-only buttons
    assert(
      semanticsLabel != null,
      'AppIconButton requires a semanticsLabel for accessibility. '
      'Provide a descriptive label like "Back", "Settings", "Delete", etc.',
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticsLabel!,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: InkWell(
          onTap: isEnabled ? () {
            if (enableHaptics) HapticFeedback.lightImpact();
            onPressed!();
          } : null,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: isEnabled 
                  ? (color ?? (context.textPrimary))
                  : (isDark ? AppOverlays.white30 : AppOverlays.black30),
            ),
          ),
        ),
      ),
    );
  }
}
