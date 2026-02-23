import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../core/app_states.dart';

export '../core/app_states.dart' show AppEmptyState;

/// Standardised empty-state widget for use across all screens.
///
/// Thin wrapper around [AppEmptyState] with aquarium-app defaults:
/// - Primary colour icon background
/// - Consistent vertical padding
/// - Optional action button using design tokens
///
/// Use [AppEmptyState] factories directly for named scenarios
/// (`.noItems`, `.noResults`, `.offline`, `.error`).
///
/// Tokens used:
/// - [AppColors.primary] for icon/action colours
/// - [AppTypography.title] for title
/// - [AppTypography.body] for subtitle
/// - [AppSpacing] for layout
///
/// Accessibility:
/// - Icon container is decorative (not announced by screen readers)
/// - Title is the primary semantic label for the region
/// - Action button exposes a semantic button role
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.pest_control_rodent,
///   title: 'No livestock yet',
///   subtitle: 'Add your first fish to get started.',
///   actionLabel: 'Add Fish',
///   onAction: () => navigateToAddFish(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Decorative icon displayed in the circular container.
  final IconData icon;

  /// Primary heading.
  final String title;

  /// Supporting text beneath the title.
  final String? subtitle;

  /// Label for the primary call-to-action button.
  /// No button rendered when null.
  final String? actionLabel;

  /// Callback for the primary action.
  final VoidCallback? onAction;

  /// Icon colour. Defaults to [AppColors.primary].
  final Color? iconColor;

  /// Use compact layout (smaller icon, reduced padding).
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      message: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: iconColor ?? AppColors.primary,
      compact: compact,
    );
  }
}
