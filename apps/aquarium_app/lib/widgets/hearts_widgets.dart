/// UI widgets for the hearts/lives system
/// Includes hearts indicator, animations, and "out of hearts" modal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hearts_service.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import 'dart:async';

/// Heart indicator widget for app bar (shows current/max hearts)
class HeartIndicator extends ConsumerWidget {
  final bool compact;

  const HeartIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();

    final hearts = profile.hearts;
    final maxHearts = HeartsConfig.maxHearts;

    // Compact mode: dark overlay style for use on scene backgrounds
    // Full mode: standard error-tinted style
    final bgColor = compact
        ? const Color(0x55000000)
        : (hearts == 0 ? AppOverlays.error10 : AppOverlays.error15);
    final borderColor = compact
        ? const Color(0x40FFFFFF)
        : (hearts == 0 ? AppColors.error : AppOverlays.error30);
    final iconColor = compact
        ? Colors.white
        : (hearts > 0 ? AppColors.error : AppOverlays.error50);
    final textColor = compact
        ? Colors.white
        : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: compact ? AppRadius.md2Radius : AppRadius.mediumRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hearts > 0 ? Icons.favorite : Icons.favorite_border,
            size: compact ? 14 : 16,
            color: iconColor,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            '$hearts/$maxHearts',
            style:
                (compact ? AppTypography.labelSmall : AppTypography.labelMedium)
                    .copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
          ),
        ],
      ),
    );
  }
}

/// Detailed hearts display with countdown timer
class DetailedHeartsDisplay extends ConsumerStatefulWidget {
  const DetailedHeartsDisplay({super.key});

  @override
  ConsumerState<DetailedHeartsDisplay> createState() =>
      _DetailedHeartsDisplayState();
}

class _DetailedHeartsDisplayState extends ConsumerState<DetailedHeartsDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every second to show countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();

    final heartsService = ref.watch(heartsServiceProvider);
    final heartsDisplay = heartsService.getHeartsDisplay();
    final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppOverlays.error10,
            AppOverlays.error5,
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.error20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...heartsDisplay.map(
                (filled) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    filled ? Icons.favorite : Icons.favorite_border,
                    color: filled
                        ? AppColors.error
                        : AppOverlays.error30,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          if (timeUntilRefill != null) ...[
            Row(
              children: [
                Icon(Icons.schedule, size: AppIconSizes.xs, color: context.textSecondary),
                const SizedBox(width: AppSpacing.xs2),
                Text(
                  'Next heart in ${heartsService.formatTimeRemaining(timeUntilRefill)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Hearts are full!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated heart loss/gain widget
class HeartAnimation extends StatefulWidget {
  final bool gained; // true = gained heart, false = lost heart
  final VoidCallback? onComplete;

  const HeartAnimation({super.key, required this.gained, this.onComplete});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kQuizRevealDelay,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: AppCurves.standardDecelerate)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.standardAccelerate)),
        weight: 20,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 40),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: AppCurves.standardAccelerate),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, widget.gained ? -0.5 : 0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standardDecelerate));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.gained ? Icons.favorite : Icons.heart_broken,
                    color: widget.gained ? AppColors.success : AppColors.error,
                    size: AppIconSizes.xxl,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.gained ? '+1' : '-1',
                    style: AppTypography.headlineLarge.copyWith(
                      color: widget.gained
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Out of Hearts" modal with options
class OutOfHeartsModal extends ConsumerStatefulWidget {
  const OutOfHeartsModal({super.key});

  @override
  ConsumerState<OutOfHeartsModal> createState() => _OutOfHeartsModalState();
}

class _OutOfHeartsModalState extends ConsumerState<OutOfHeartsModal> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every second to show countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    final heartsService = ref.watch(heartsServiceProvider);
    final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sad emoji
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppOverlays.error10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('💔', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 56)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg2),

            // Title
            Text(
              'Out of Hearts',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm2),

            // Description
            Text(
              'You need hearts to continue lessons. Try practice mode or wait for hearts to refill!',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Countdown timer
            if (timeUntilRefill != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Next heart in ${heartsService.formatTimeRemaining(timeUntilRefill)}',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Options
            Column(
              children: [
                // Practice mode button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop('practice');
                  },
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Practice to Earn Heart'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm2),

                // Wait button
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop('wait');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Wait for Refill'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the out of hearts modal
Future<String?> showOutOfHeartsModal(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const OutOfHeartsModal(),
  );
}

/// Compact hearts display for lesson screens
class CompactHeartsDisplay extends ConsumerWidget {
  const CompactHeartsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();

    final heartsService = ref.watch(heartsServiceProvider);
    final heartsDisplay = heartsService.getHeartsDisplay();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: heartsDisplay
          .map(
            (filled) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                color: filled
                    ? AppColors.error
                    : AppOverlays.error30,
                size: AppIconSizes.sm,
              ),
            ),
          )
          .toList(),
    );
  }
}
