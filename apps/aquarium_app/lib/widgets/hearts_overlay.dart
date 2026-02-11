/// Hearts overlay - Full-screen animated feedback for heart changes
/// Shows when user gains or loses a heart with dramatic animation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/hearts_service.dart';
import '../providers/user_profile_provider.dart';
import 'dart:async';

/// Global key for hearts overlay to trigger from anywhere
final GlobalKey<NavigatorState> heartsOverlayKey = GlobalKey<NavigatorState>();

/// Show an animated hearts change overlay
Future<void> showHeartsChangeOverlay(
  BuildContext context, {
  required bool gained,
  Duration duration = const Duration(milliseconds: 1500),
}) async {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) =>
        HeartsChangeOverlay(gained: gained, duration: duration),
  );

  overlay.insert(overlayEntry);

  // Auto-remove after animation completes
  await Future.delayed(duration);
  overlayEntry.remove();
}

/// Animated overlay showing heart gain/loss
class HeartsChangeOverlay extends StatefulWidget {
  final bool gained;
  final Duration duration;

  const HeartsChangeOverlay({
    super.key,
    required this.gained,
    required this.duration,
  });

  @override
  State<HeartsChangeOverlay> createState() => _HeartsChangeOverlayState();
}

class _HeartsChangeOverlayState extends State<HeartsChangeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Scale up quickly, then down
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.5), weight: 30),
    ]).animate(_controller);

    // Fade in and out
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    // Slide up or down based on gained/lost
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, widget.gained ? -0.3 : 0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Slight rotation for drama
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.gained ? 0.1 : -0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: widget.gained
                            ? AppColors.success.withOpacity(0.95)
                            : AppColors.error.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (widget.gained
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.gained ? Icons.favorite : Icons.heart_broken,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.gained ? '+1 Heart' : '-1 Heart',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.gained ? 'Great job! 🎉' : 'Keep trying! 💪',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Widget that wraps content and shows hearts status with auto-refill timer
class HeartsStatusBanner extends ConsumerStatefulWidget {
  final Widget child;
  final bool showTimer;

  const HeartsStatusBanner({
    super.key,
    required this.child,
    this.showTimer = true,
  });

  @override
  ConsumerState<HeartsStatusBanner> createState() => _HeartsStatusBannerState();
}

class _HeartsStatusBannerState extends ConsumerState<HeartsStatusBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.showTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final heartsService = ref.watch(heartsServiceProvider);

    if (profile == null) return widget.child;

    final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);
    final showBanner =
        profile.hearts < HeartsConfig.maxHearts &&
        timeUntilRefill != null &&
        widget.showTimer;

    return Stack(
      children: [
        widget.child,
        if (showBanner)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Material(
              color: AppColors.error.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Next heart in ${heartsService.formatTimeRemaining(timeUntilRefill)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Helper mixin for screens that need hearts functionality
mixin HeartsScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Consume a heart with visual feedback
  Future<bool> consumeHeart() async {
    final heartsService = ref.read(heartsServiceProvider);
    final success = await heartsService.loseHeart();

    if (success && mounted) {
      await showHeartsChangeOverlay(context, gained: false);
    }

    return success;
  }

  /// Award a heart with visual feedback
  Future<bool> awardHeart() async {
    final heartsService = ref.read(heartsServiceProvider);
    final success = await heartsService.gainHeart();

    if (success && mounted) {
      await showHeartsChangeOverlay(context, gained: true);
    }

    return success;
  }

  /// Check if user can continue (has hearts)
  bool canContinue() {
    final heartsService = ref.read(heartsServiceProvider);
    return heartsService.hasHeartsAvailable;
  }

  /// Show out of hearts dialog
  Future<String?> showOutOfHeartsDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.heart_broken, color: AppColors.error),
            SizedBox(width: 8),
            Text('Out of Hearts'),
          ],
        ),
        content: const Text(
          'You need hearts to continue lessons. Try practice mode to earn hearts or wait for them to refill!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'practice'),
            child: const Text('Practice Mode'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'wait'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
