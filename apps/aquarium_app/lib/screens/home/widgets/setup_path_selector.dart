import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../../create_tank_screen/setup_mode.dart';

/// Two-card selector for the empty-tank scene.
///
/// Lets the user pick between a guided 3-page wizard and an expert
/// single-form tank creation flow. The selected [SetupMode] is passed
/// back via [onPathSelected]; the parent ([EmptyRoomScene]) then
/// navigates to [CreateTankScreen] with that mode.
///
/// Responsive: lays out as a [Row] on wider screens (≥360 dp) and
/// stacks to a [Column] on narrow devices so the cards never squish.
class SetupPathSelector extends StatelessWidget {
  /// Fired with the selected mode when either card is tapped.
  final ValueChanged<SetupMode> onPathSelected;

  /// Whether tapping a card should play a light haptic.
  ///
  /// Defaults to true — matches [AppButton] which fires
  /// [HapticFeedback.lightImpact] unconditionally.
  final bool enableHaptics;

  const SetupPathSelector({
    super.key,
    required this.onPathSelected,
    this.enableHaptics = true,
  });

  void _handleTap(SetupMode mode) {
    if (enableHaptics) {
      HapticFeedback.lightImpact();
    }
    onPathSelected(mode);
  }

  @override
  Widget build(BuildContext context) {
    final guided = _PathCard(
      mode: SetupMode.guided,
      icon: Icons.auto_awesome_outlined,
      title: 'Guide me',
      subtitle: '3 quick steps with tips along the way',
      semanticsHint: 'Start a guided 3-step tank setup',
      onTap: () => _handleTap(SetupMode.guided),
    );

    final expert = _PathCard(
      mode: SetupMode.expert,
      icon: Icons.bolt_outlined,
      title: 'I know the ropes',
      subtitle: 'Skip the wizard — just the essentials',
      semanticsHint: 'Start an expert single-form tank setup',
      onTap: () => _handleTap(SetupMode.expert),
    );

    // Use MediaQuery instead of LayoutBuilder: LayoutBuilder inside a
    // Positioned child with unbounded height constraints (the pattern used
    // by _ContentPanel in empty_room_scene.dart) breaks intrinsic sizing
    // further up the tree. MediaQuery gives us the screen width without
    // participating in layout.
    final screenWidth = MediaQuery.of(context).size.width;
    // Below 360 dp, stack vertically so cards keep a usable tap target
    // and text doesn't wrap awkwardly.
    if (screenWidth < 360) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          guided,
          const SizedBox(height: AppSpacing.sm),
          expert,
        ],
      );
    }
    // Plain Row with natural-height cards. Avoiding `stretch` + `Expanded`
    // + `IntrinsicHeight` combinations that break when placed inside a
    // bottom-anchored Positioned (loose height constraint). Cards may be
    // slightly different heights if copy lengths differ; that's fine
    // visually since their content is left-aligned.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: guided),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: expert),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  final SetupMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final String semanticsHint;
  final VoidCallback onTap;

  const _PathCard({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.semanticsHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? DanioColors.notebookDark
        : DanioColors.ivoryWhite;
    final borderColor = isDark
        ? AppOverlays.white10
        : DanioColors.notebookBorderLight;

    return Semantics(
      button: true,
      label: title,
      hint: semanticsHint,
      child: Material(
        color: background,
        elevation: 0,
        borderRadius: AppRadius.mediumRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm2,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackAlpha08,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            // IntrinsicHeight keeps both cards the same height when sitting
            // side-by-side, without forcing a fixed minHeight that would
            // overflow if either card's subtitle wraps to a second line.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
