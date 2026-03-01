import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Screen header for room-based screens.
///
/// Displays a room emoji, title, and optional subtitle slot.
///
/// Example:
/// ```dart
/// RoomHeader(
///   emoji: '🐠',
///   title: 'My Aquarium',
///   subtitle: Text('3 fish, 2 plants'),
/// )
/// ```
class RoomHeader extends StatelessWidget {
  /// Emoji displayed before the title
  final String emoji;

  /// Header title text
  final String title;

  /// Optional subtitle widget (flexible slot)
  final Widget? subtitle;

  /// Optional trailing widget (e.g. settings icon)
  final Widget? trailing;

  const RoomHeader({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm2,
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
