import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';

/// Floating ambient tip that appears occasionally on the home screen.
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
    '💧 Weekly water changes keep your fish happy',
    '🌡️ Stable temperature matters more than exact numbers',
    '🧪 Test your water weekly, especially during cycling',
    '🐟 Never add more than 3 fish at a time',
    '🪴 Live plants absorb nitrates naturally',
    '🧂 A pinch of aquarium salt helps stressed fish',
    '🔬 Ammonia at 0 ppm is always the goal',
    '📅 Log your water changes to spot patterns',
    '🐠 Most tropical fish prefer 24-26°C',
    '💡 8-10 hours of light daily prevents algae',
    '🧽 Clean your filter in old tank water, never tap',
    '🌊 Good flow prevents dead spots and algae',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.5, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scheduleNext();
  }

  void _scheduleNext() {
    final delay = Duration(seconds: 45 + _rng.nextInt(46)); // 45–90s
    _timer = Timer(delay, _showTip);
  }

  void _showTip() {
    if (!mounted) return;
    final stage = ref.read(stageProvider);
    if (stage.openPanels.isNotEmpty) {
      _scheduleNext();
      return;
    }

    // Pick unseen tip
    final available = List.generate(_tips.length, (i) => i)
        .where((i) => !_shownTips.contains(i))
        .toList();
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

    // Auto-dismiss after 6 seconds
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

    return Positioned(
      bottom: 80,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onPanEnd: (_) => _dismiss(),
            onTap: _dismiss,
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm2,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.theme.glassCard,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: widget.theme.glassBorder, width: 0.5),
                image: const DecorationImage(
                  image: AssetImage('assets/textures/felt-teal.png'),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentTip!,
                      style: AppTypography.bodySmall.copyWith(
                        color: widget.theme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: widget.theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
