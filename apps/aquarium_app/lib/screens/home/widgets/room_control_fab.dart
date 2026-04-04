import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/speed_dial_fab.dart';

/// Speed Dial FAB for quick actions from the home screen.
/// Stateless — only rebuilds when its callbacks or visibility change.
class RoomControlFAB extends StatelessWidget {
  final bool isHidden;
  final VoidCallback onStats;
  final VoidCallback onWaterChange;
  final VoidCallback onFeed;
  final VoidCallback onQuickTest;
  final VoidCallback onAddTank;

  const RoomControlFAB({
    super.key,
    required this.isHidden,
    required this.onStats,
    required this.onWaterChange,
    required this.onFeed,
    required this.onQuickTest,
    required this.onAddTank,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 130 + MediaQuery.of(context).padding.bottom,
      right: AppSpacing.md,
      child: IgnorePointer(
        ignoring: isHidden,
        child: Opacity(
          opacity: isHidden ? 0.0 : 1.0,
          child: SpeedDialFAB(
            actions: [
              SpeedDialAction(
                icon: Icons.calendar_view_month_rounded,
                label: 'Stats',
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: AppColors.primary,
                onPressed: onStats,
              ),
              SpeedDialAction(
                icon: Icons.water_drop_rounded,
                label: 'Water Change',
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                onPressed: onWaterChange,
              ),
              SpeedDialAction(
                icon: Icons.restaurant_rounded,
                label: 'Feed',
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: DanioColors.coralAccent,
                onPressed: onFeed,
              ),
              SpeedDialAction(
                icon: Icons.science_rounded,
                label: 'Quick Test',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: onQuickTest,
              ),
              SpeedDialAction(
                icon: Icons.water_rounded,
                label: 'Add Tank',
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                onPressed: onAddTank,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
