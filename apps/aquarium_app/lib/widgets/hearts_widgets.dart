/// UI widgets for the energy system (previously hearts/lives)
/// Includes energy indicator, animations, and "low energy" info modal.
/// Energy is a soft pacing signal — depleted energy does NOT block learning.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_button.dart';
import '../services/hearts_service.dart';
import '../providers/user_profile_provider.dart';
import '../providers/gems_provider.dart';
import '../screens/gem_shop_screen.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import 'dart:async';

/// Energy indicator widget for app bar (shows current/max energy)
class HeartIndicator extends ConsumerWidget {
  final bool compact;

  const HeartIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(
      userProfileProvider.select((a) => a.value?.hearts),
    );
    if (energy == null) return const SizedBox.shrink();

    final maxEnergy = HeartsConfig.maxHearts;
    final isEmpty = energy <= 0;

    // Compact mode: dark overlay style for use on scene backgrounds
    // Full mode: standard amber/warning tinted style for energy
    final bgColor = compact
        ? const Color(0x55000000)
        : (isEmpty ? const Color(0x1AFFA000) : const Color(0x26FFA000));
    final borderColor = compact
        ? const Color(0x40FFFFFF)
        : (isEmpty ? const Color(0xFFFFA000) : const Color(0x4DFFA000));
    final iconColor = compact
        ? Colors.white
        : (isEmpty ? const Color(0x80FFA000) : const Color(0xFFFFA000));
    final textColor = compact ? Colors.white : const Color(0xFFFFA000);

    return Semantics(
      liveRegion: true,
      label: '$energy of $maxEnergy energy remaining',
      child: Container(
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
              isEmpty ? Icons.flash_off : Icons.flash_on,
              size: compact ? 14 : 16,
              color: iconColor,
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              '$energy/$maxEnergy',
              style:
                  (compact ? AppTypography.labelSmall : AppTypography.labelMedium)
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider.select((p) => p.value));
    if (profile == null) return const SizedBox.shrink();

    final heartsService = ref.watch(heartsServiceProvider);
    final heartsDisplay = heartsService.getHeartsDisplay();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x1AFFA000), Color(0x0DFFA000)],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: const Color(0x33FFA000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...heartsDisplay.map(
                (filled) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    filled ? Icons.flash_on : Icons.flash_off,
                    color: filled ? const Color(0xFFFFA000) : const Color(0x4DFFA000),
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          ValueListenableBuilder<int>(
            valueListenable: _tick,
            builder: (_, __, ___) {
              final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);
              if (timeUntilRefill != null) {
                return Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: AppIconSizes.xs,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs2),
                    Text(
                      'Next ⚡ in ${heartsService.formatTimeRemaining(timeUntilRefill)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                );
              }
              return Text(
                '⚡ Energy is full!',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
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
  bool _disableMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kQuizRevealDelay, vsync: this);

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

    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(0, widget.gained ? -0.5 : 0.5),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppCurves.standardDecelerate,
          ),
        );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newValue = MediaQuery.of(context).disableAnimations;
    if (newValue != _disableMotion) {
      _disableMotion = newValue;
      _controller.duration = _disableMotion ? Duration.zero : kQuizRevealDelay;
    }
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
                    widget.gained ? Icons.flash_on : Icons.flash_off,
                    color: widget.gained ? AppColors.success : const Color(0xFFFFA000),
                    size: AppIconSizes.xxl,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.gained ? '+1 ⚡' : '-1 ⚡',
                    style: AppTypography.headlineLarge.copyWith(
                      color: widget.gained
                          ? AppColors.success
                          : const Color(0xFFFFA000),
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

/// Energy depleted info modal — informational only, does NOT block learning.
/// Explains that the user can continue without bonus XP.
class OutOfHeartsModal extends ConsumerStatefulWidget {
  const OutOfHeartsModal({super.key});

  @override
  ConsumerState<OutOfHeartsModal> createState() => _OutOfHeartsModalState();
}

class _OutOfHeartsModalState extends ConsumerState<OutOfHeartsModal> {
  Timer? _timer;
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider.select((p) => p.value));
    if (profile == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    final heartsService = ref.watch(heartsServiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Energy icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0x1AFFA000),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '⚡',
                  style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg2),

            // Title
            Text(
              'Energy Depleted',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm2),

            // Description — explicitly tells user they can keep learning
            Text(
              'Your energy is out, but you can keep learning! Bonus XP is paused until your energy refills. No pressure to stop.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Countdown timer
            ValueListenableBuilder<int>(
              valueListenable: _tick,
              builder: (_, __, ___) {
                final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);
                if (timeUntilRefill == null) return const SizedBox.shrink();
                return Container(
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
                        'Next ⚡ in ${heartsService.formatTimeRemaining(timeUntilRefill)}',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Gem balance — refill option
            Builder(
              builder: (context) {
                final gemBalance = ref.watch(gemBalanceProvider);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.info10,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$gemBalance gems',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton(
                        label: 'Refill Energy',
                        onPressed: () {
                          Navigator.of(context).pop('shop');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GemShopScreen(),
                            ),
                          );
                        },
                        variant: AppButtonVariant.text,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Actions — continue or dismiss
            Column(
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.of(context).pop('continue');
                  },
                  label: 'Keep Learning',
                  leadingIcon: Icons.play_arrow,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: AppSpacing.sm2),
                AppButton(
                  label: 'Take a Break',
                  onPressed: () {
                    Navigator.of(context).pop('break');
                  },
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the energy info modal (informational only, does not block)
Future<String?> showOutOfHeartsModal(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const OutOfHeartsModal(),
  );
}

/// Compact energy display for lesson screens
class CompactHeartsDisplay extends ConsumerWidget {
  const CompactHeartsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider.select((p) => p.value));
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
                filled ? Icons.flash_on : Icons.flash_off,
                color: filled ? const Color(0xFFFFA000) : const Color(0x4DFFA000),
                size: AppIconSizes.sm,
              ),
            ),
          )
          .toList(),
    );
  }
}
