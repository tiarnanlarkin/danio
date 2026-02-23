import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_card.dart';

/// A warm, cozy-styled card wrapper around [AppCard].
///
/// Provides rounded xl corners, a soft warm shadow, and a warm background tint
/// inspired by the app's cozy room aesthetic.
///
/// Example:
/// ```dart
/// CozyCard(
///   child: Text('Welcome home!'),
/// )
/// ```
class CozyCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Optional tap handler
  final VoidCallback? onTap;

  /// Custom padding (defaults to spacious)
  final EdgeInsets? padding;

  /// Optional header widget
  final Widget? header;

  /// Optional footer widget
  final Widget? footer;

  const CozyCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: AppCardPadding.spacious,
      customPadding: padding,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      backgroundColor: isDark
          ? const Color(0xFF2D2B3A) // warm dark surface
          : const Color(0xFFFFFBF5), // warm cream
      boxShadow: AppShadows.cozyWarm,
      onTap: onTap,
      header: header,
      footer: footer,
      child: child,
    );
  }
}
