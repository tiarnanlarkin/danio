import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_button.dart';

export '../core/app_button.dart' show AppButton, AppButtonVariant, AppButtonSize;

/// Standardised primary action button.
///
/// Filled with [AppColors.primary]. Should be used for the single most
/// important action on a screen or card. Use sparingly — one per view.
///
/// Tokens used:
/// - [AppColors.primary] fill colour
/// - [AppColors.onPrimary] text/icon colour
/// - [AppRadius.smallRadius] for shape
/// - [AppTypography.label] for text
/// - [AppTouchTargets.minimum] (48 dp) minimum touch target height
///
/// Accessibility:
/// - [semanticsLabel] defaults to [label] if not provided
/// - Disabled state is communicated via Semantics.enabled
/// - Haptic feedback on press (override with [enableHaptics] = false)
///
/// Example:
/// ```dart
/// PrimaryButton(
///   label: 'Save Changes',
///   onPressed: _save,
///   isLoading: _saving,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// Button label.
  final String label;

  /// Callback when pressed. Null disables the button.
  final VoidCallback? onPressed;

  /// Shows loading spinner and disables interaction.
  final bool isLoading;

  /// Expands the button to fill the parent width.
  final bool isFullWidth;

  /// Optional leading icon.
  final IconData? leadingIcon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// Semantic label for screen readers. Defaults to [label].
  final String? semanticsLabel;

  /// Button size. Defaults to [AppButtonSize.medium] (48 dp height).
  final AppButtonSize size;

  /// Whether to fire haptic feedback on press. Defaults to true.
  final bool enableHaptics;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.semanticsLabel,
    this.size = AppButtonSize.medium,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      semanticsLabel: semanticsLabel,
      enableHaptics: enableHaptics,
    );
  }
}

/// Standardised secondary action button.
///
/// Outlined style using [AppColors.primary] border and text.
/// Represents a non-destructive secondary action (cancel, back, skip).
///
/// Tokens used:
/// - [AppColors.primary] border and text colour
/// - Transparent background
/// - [AppRadius.smallRadius] for shape
/// - [AppTypography.label] for text
/// - [AppTouchTargets.minimum] (48 dp) minimum touch target height
///
/// Accessibility:
/// - [semanticsLabel] defaults to [label] if not provided
/// - Disabled state communicated via Semantics.enabled
///
/// Example:
/// ```dart
/// SecondaryButton(
///   label: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  /// Button label.
  final String label;

  /// Callback when pressed. Null disables the button.
  final VoidCallback? onPressed;

  /// Shows loading spinner and disables interaction.
  final bool isLoading;

  /// Expands the button to fill the parent width.
  final bool isFullWidth;

  /// Optional leading icon.
  final IconData? leadingIcon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// Semantic label for screen readers. Defaults to [label].
  final String? semanticsLabel;

  /// Button size. Defaults to [AppButtonSize.medium] (48 dp height).
  final AppButtonSize size;

  /// Whether to fire haptic feedback on press. Defaults to true.
  final bool enableHaptics;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.semanticsLabel,
    this.size = AppButtonSize.medium,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      semanticsLabel: semanticsLabel,
      enableHaptics: enableHaptics,
    );
  }
}
