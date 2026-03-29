// dart:ui import removed — BackdropFilter replaced with solid overlay (perf: T-D-270)
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

/// Small frosted pill showing tank name + volume at bottom-right of tank glass.
class TankGlassBadge extends StatefulWidget {
  final String tankName;
  final double tankVolume;
  final RoomTheme theme;

  const TankGlassBadge({
    super.key,
    required this.tankName,
    required this.tankVolume,
    required this.theme,
  });

  @override
  State<TankGlassBadge> createState() => _TankGlassBadgeState();
}

class _TankGlassBadgeState extends State<TankGlassBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.long1,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    // Delay 600ms before fading in
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _controller.duration = disableMotion ? Duration.zero : AppDurations.long1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm3),
            decoration: BoxDecoration(
              color: widget.theme.glassCard,
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: widget.theme.glassBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.tankName} · ${widget.tankVolume.toStringAsFixed(0)}L',
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.theme.textPrimary,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
