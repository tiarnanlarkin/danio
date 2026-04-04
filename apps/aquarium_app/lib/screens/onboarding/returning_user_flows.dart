import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

// =============================================================================
// Returning User Flow Widgets
//
// Reusable widgets for Day 2, Day 7, and Day 30 returning user experiences.
// These are NOT full screens — they're composable widgets meant to be shown
// inside bottom sheets, inline on the home screen, etc.
// =============================================================================

/// Day 2 — Bottom sheet streak prompt
///
/// Show via `showAppBottomSheet` when the user returns on Day 2.
/// Flame icon with animated flicker, streak message, and CTA.
class Day2StreakPrompt extends StatefulWidget {
  final String? fishName;
  final VoidCallback onContinue;
  final VoidCallback onDismiss;

  const Day2StreakPrompt({
    super.key,
    this.fishName,
    required this.onContinue,
    required this.onDismiss,
  });

  @override
  State<Day2StreakPrompt> createState() => _Day2StreakPromptState();
}

class _Day2StreakPromptState extends State<Day2StreakPrompt>
    with SingleTickerProviderStateMixin {

  late final AnimationController _flickerController;
  late final CurvedAnimation _flickerCurve;
  late final Animation<double> _flickerScale;

  @override
  void initState() {
    super.initState();

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flickerCurve = CurvedAnimation(
      parent: _flickerController,
      curve: Curves.easeInOut,
    );
    _flickerScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(_flickerCurve);

    if (!disableAnimations) {
      _flickerController.repeat();
    } else {
      _flickerController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _flickerCurve.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Day 2 streak prompt',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.textHint.withAlpha(60),
                borderRadius: AppRadius.xxsRadius,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Flame icon with flicker
            AnimatedBuilder(
              animation: _flickerScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flickerScale.value,
                  child: child,
                );
              },
              child: const Text('🔥', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: AppSpacing.md),
            // Headline
            Text(
              'Day 2 🔥 Your streak is alive. Keep it going.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.fishName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Today's lesson is about ${widget.fishName}.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            // CTA button
            AppButton(
              label: 'Continue learning →',
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onContinue();
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              size: AppButtonSize.large,
              semanticsLabel: 'Continue learning',
            ),
            const SizedBox(height: AppSpacing.sm2),
            // Later link
            AppButton(
              label: 'Later',
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onDismiss();
              },
              variant: AppButtonVariant.text,
              isFullWidth: true,
              semanticsLabel: 'Later, dismiss streak prompt',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

/// Day 7 — Inline milestone card
///
/// Gold/amber background card celebrating the 7-day streak with XP bonus
/// and a feature nudge.
class Day7MilestoneCard extends StatefulWidget {
  final VoidCallback? onFeatureTap;

  const Day7MilestoneCard({
    super.key,
    this.onFeatureTap,
  });

  @override
  State<Day7MilestoneCard> createState() => _Day7MilestoneCardState();
}

class _Day7MilestoneCardState extends State<Day7MilestoneCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _xpController;
  late final CurvedAnimation _xpCurve;
  late final Animation<double> _xpScale;

  @override
  void initState() {
    super.initState();

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    _xpController = AnimationController(
      vsync: this,
      duration: AppDurations.long2,
    );
    _xpCurve = CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeOut,
    );
    _xpScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(_xpCurve);

    if (!disableAnimations) {
      // Delay XP animation slightly so the card has rendered
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _xpController.forward();
      });
    } else {
      _xpController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _xpCurve.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '7 day milestone, you earned Apprentice Fishkeeper, plus 50 XP bonus',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardingAmber,
              AppColors.onboardingAmber.withAlpha(210),
            ],
          ),
          borderRadius: AppRadius.lg2Radius,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trophy + headline
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 36)),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    "7 days — You've earned Apprentice Fishkeeper",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // XP bonus
            AnimatedBuilder(
              animation: _xpScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _xpScale.value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm4, vertical: AppSpacing.xs2),
                decoration: BoxDecoration(
                  color: AppColors.whiteAlpha20,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '+50 XP bonus',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
            // Feature nudge
            if (widget.onFeatureTap != null) ...[
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Try the tank compatibility checker',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onFeatureTap?.call();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm4,
                      vertical: AppSpacing.sm2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteAlpha15,
                      borderRadius: AppRadius.md2Radius,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Have you tried the tank compatibility checker?',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.onPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================

/// Day 30 — Inline card for free users
///
/// Celebrates 30 days of usage with a usage summary and soft CTA to upgrade.
class Day30CommittedCard extends StatelessWidget {
  final int lessonsCompleted;
  final int xpEarned;
  // FB-B4: onUpgrade is nullable — pass null to hide the CTA when no
  // upgrade destination exists yet. This prevents the button from just
  // closing the dialog with no visible effect.
  final VoidCallback? onUpgrade;

  const Day30CommittedCard({
    super.key,
    required this.lessonsCompleted,
    required this.xpEarned,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '30 days of Danio. $lessonsCompleted lessons completed, $xpEarned XP earned.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: AppRadius.lg2Radius,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            Text(
              '30 days of Danio 🎣',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Usage summary
            _buildStatRow(context, Icons.menu_book_rounded, '$lessonsCompleted lessons completed'),
            const SizedBox(height: AppSpacing.sm3),
            _buildStatRow(context, Icons.star_rounded, '$xpEarned XP earned'),
            // FB-B4: Only show the upgrade CTA when a real destination is wired up.
            // When onUpgrade is null the button is hidden — avoids it just closing the dialog.
            if (onUpgrade != null) ...[
              const SizedBox(height: AppSpacing.lg2),
              AppButton(
                label: "See what's waiting for you →",
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onUpgrade!();
                },
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                semanticsLabel: "See what's waiting for you, upgrade",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm3),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
