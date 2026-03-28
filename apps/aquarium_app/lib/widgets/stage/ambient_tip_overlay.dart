import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';

/// Floating ambient tip that appears occasionally on the home screen.
/// Uses Align+Padding instead of Positioned so it works correctly as a
/// non-positioned child of the parent Stack (avoids eating full-screen touches).
class AmbientTipOverlay extends ConsumerStatefulWidget {
  final RoomTheme theme;

  const AmbientTipOverlay({super.key, required this.theme});

  @override
  ConsumerState<AmbientTipOverlay> createState() => _AmbientTipOverlayState();
}

class _AmbientTipOverlayState extends ConsumerState<AmbientTipOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  String? _currentTip;
  final _shownTips = <int>{};
  final _rng = math.Random();

  static const _tips = [
    '\u{1F4A7} Weekly water changes keep your fish happy',
    '\u{1F321}\u{FE0F} Stable temperature matters more than exact numbers',
    '\u{1F9EA} Test your water weekly, especially during cycling',
    '\u{1F41F} Never add more than 3 fish at a time',
    '\u{1FAB4} Live plants absorb nitrates naturally',
    '\u{1F9C2} A pinch of aquarium salt helps stressed fish',
    '\u{1F52C} Ammonia at 0 ppm is always the goal',
    '\u{1F4C5} Log your water changes to spot patterns',
    '\u{1F420} Most tropical fish prefer 24-26\u{00B0}C',
    '\u{1F4A1} 8-10 hours of light daily prevents algae',
    '\u{1F9FD} Clean your filter in old tank water, never tap',
    '\u{1F30A} Good flow prevents dead spots and algae',
  ];

  @override
  void initState() {
    super.initState();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _animController = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.5, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _scheduleNext();
  }

  void _scheduleNext() {
    final delay = Duration(seconds: 45 + _rng.nextInt(46));
    _timer = Timer(delay, _showTip);
  }

  void _showTip() {
    if (!mounted) return;
    final stage = ref.read(stageProvider);
    if (stage.openPanels.isNotEmpty) {
      _scheduleNext();
      return;
    }

    final available = List.generate(
      _tips.length,
      (i) => i,
    ).where((i) => !_shownTips.contains(i)).toList();
    if (available.isEmpty) {
      _shownTips.clear();
      _scheduleNext();
      return;
    }

    final idx = available[_rng.nextInt(available.length)];
    _shownTips.add(idx);

    setState(() => _currentTip = _tips[idx]);
    _animController.forward(from: 0);
    HapticFeedback.lightImpact();

    Future.delayed(const Duration(seconds: 6), _dismiss);
  }

  void _dismiss() {
    if (!mounted || _currentTip == null) return;
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() => _currentTip = null);
        _scheduleNext();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTip == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 140, left: AppSpacing.md, right: AppSpacing.md),
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Semantics(
              label: 'Tip card. Tap or swipe to dismiss.',
              button: true,
              child: GestureDetector(
                onPanEnd: (_) => _dismiss(),
                onTap: _dismiss,
                child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm2,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.glassCard,
                  borderRadius: AppRadius.largeRadius,
                  border: Border.all(
                    color: widget.theme.glassBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackAlpha20,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/textures/felt-teal.webp'),
                    fit: BoxFit.cover,
                    opacity: 0.15,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 20,
                      color: widget.theme.accentCircles.isNotEmpty
                          ? widget.theme.accentCircles[0]
                          : widget.theme.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm2),
                    Expanded(
                      child: Text(
                        _currentTip!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: widget.theme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Semantics(
                      button: true,
                      label: 'Dismiss tip',
                      child: GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
