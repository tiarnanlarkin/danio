import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_card.dart';

/// A warm, rounded card that fits the cosy aquarium app aesthetic.
///
/// Built on [AppCard] with opinionated defaults:
/// - Rounded corners (AppRadius.lg = 24 dp)
/// - Elevated variant with AppShadows.soft
/// - Standard padding (AppSpacing.md = 16 dp)
/// - Warm background tint in dark mode
///
/// Use this as the default content container across room screens and dashboards.
///
/// Example:
/// ```dart
/// CozyCard(
///   semanticsLabel: 'Tank overview',
///   onTap: () => navigateToDetail(),
///   child: TankSummaryWidget(),
/// )
/// ```
class CozyCard extends StatelessWidget {
  /// Primary content of the card.
  final Widget child;

  /// Custom inner padding. Defaults to [AppSpacing.md] on all sides.
  final EdgeInsets? padding;

  /// External margin around the card.
  final EdgeInsets? margin;

  /// Custom border radius. Defaults to [AppRadius.largeRadius] (24 dp).
  final BorderRadius? borderRadius;

  /// Custom background colour. Overrides the theme default.
  final Color? backgroundColor;

  /// Callback when the card is tapped. Makes the card interactive.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Accessibility label describing the card contents.
  ///
  /// Strongly recommended when [onTap] is provided — screen readers
  /// will announce this as the button's name.
  final String? semanticsLabel;

  /// Width constraint. Expands to parent width when null.
  final double? width;

  /// Height constraint. Wraps content height when null.
  final double? height;

  const CozyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      variant: AppCardVariant.elevated,
      borderRadius: borderRadius ?? AppRadius.largeRadius,
      customPadding: padding ?? const EdgeInsets.all(AppSpacing.md),
      margin: margin,
      backgroundColor: backgroundColor ??
          (isDark ? const Color(0xFF2D2B3A) : const Color(0xFFFFFBF5)),
      boxShadow: AppShadows.soft,
      onTap: onTap,
      onLongPress: onLongPress,
      semanticsLabel: semanticsLabel,
      width: width,
      height: height,
      child: child,
    );
  }
}
