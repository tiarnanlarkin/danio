import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';

/// Quick-add FAB with expandable options
class QuickAddFab extends StatefulWidget {
  final String tankId;
  final VoidCallback onWaterTest;
  final VoidCallback onWaterChange;
  final VoidCallback onObservation;
  final VoidCallback onFeeding;

  const QuickAddFab({
    super.key,
    required this.tankId,
    required this.onWaterTest,
    required this.onWaterChange,
    required this.onObservation,
    required this.onFeeding,
  });

  @override
  State<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends State<QuickAddFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _controller = AnimationController(
      duration: disableMotion ? Duration.zero : AppDurations.medium2,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.standardDecelerate,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleAction(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FABs
        ScaleTransition(
          scale: _expandAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MiniFabOption(
                icon: Icons.science,
                label: 'Water Test',
                color: AppColors.primary,
                onTap: () => _handleAction(widget.onWaterTest),
              ),
              const SizedBox(height: AppSpacing.sm),
              MiniFabOption(
                icon: Icons.water_drop,
                label: 'Water Change',
                color: AppColors.secondary,
                onTap: () => _handleAction(widget.onWaterChange),
              ),
              const SizedBox(height: AppSpacing.sm),
              MiniFabOption(
                icon: Icons.restaurant,
                label: 'Log Feeding',
                color: AppColors.warning,
                onTap: () => _handleAction(widget.onFeeding),
              ),
              const SizedBox(height: AppSpacing.sm),
              MiniFabOption(
                icon: Icons.edit_note,
                label: 'Observation',
                color: AppColors.accentAlt,
                onTap: () => _handleAction(widget.onObservation),
              ),
              const SizedBox(height: AppSpacing.sm2),
            ],
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          tooltip: 'Quick actions menu',
          heroTag: 'main_fab_${widget.tankId}',
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: AppDurations.medium2,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class MiniFabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MiniFabOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: AppSpacing.xs2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.xsRadius,
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black10,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Material Design 3: Use 48x48 minimum touch target
        // FloatingActionButton.small is 40x40, so we use regular FAB with smaller visuals
        SizedBox(
          width: AppTouchTargets.minimum,
          height: AppTouchTargets.minimum,
          child: FloatingActionButton(
            heroTag: label,
            backgroundColor: color,
            tooltip: label,
            onPressed: onTap,
            child: Icon(icon, size: AppIconSizes.sm),
          ),
        ),
      ],
    );
  }
}
