import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 16),
            // Headline
            Text(
              'Day 2 🔥 Your streak is alive. Keep it going.',
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.fishName != null) ...[
              const SizedBox(height: 8),
              Text(
                "Today's lesson is about ${widget.fishName}.",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            // CTA button
            Semantics(
              label: 'Continue learning',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingAmber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue learning →',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Later link
            Semantics(
              label: 'Later, dismiss streak prompt',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onDismiss();
                  },
                  child: Text(
                    'Later',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
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
      duration: const Duration(milliseconds: 500),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardingAmber,
              AppColors.onboardingAmber.withAlpha(210),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trophy + headline
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "7 days — You've earned Apprentice Fishkeeper",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '+50 XP bonus',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Feature nudge
            if (widget.onFeatureTap != null) ...[
              const SizedBox(height: 16),
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
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Have you tried the tank compatibility checker?',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
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
  final VoidCallback onUpgrade;

  const Day30CommittedCard({
    super.key,
    required this.lessonsCompleted,
    required this.xpEarned,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '30 days of Danio. $lessonsCompleted lessons completed, $xpEarned XP earned.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            Text(
              '30 days of Danio 🎣',
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Usage summary
            _buildStatRow(Icons.menu_book_rounded, '$lessonsCompleted lessons completed'),
            const SizedBox(height: 10),
            _buildStatRow(Icons.star_rounded, '$xpEarned XP earned'),
            const SizedBox(height: 20),
            // Soft CTA
            Semantics(
              label: "See what's waiting for you, upgrade",
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onUpgrade();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.onboardingAmber,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "See what's waiting for you →",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingAmber,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
