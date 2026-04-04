/// Lesson Completion Celebration Overlay
///
/// Animated "quiet triumph" celebration shown when a user completes a lesson.
/// Features:
///   • Hero text spring entrance (scale 0→1, ~400ms)
///   • Badge/icon stagger fade-in (~200ms delay after hero)
///   • XP counter shimmer/count-up animation
///   • Ambient rising bubble particles (3–5 small circles)
///   • Copy variants: regular, first-lesson-ever, streak milestones, gem-earned
///   • Reduced motion fallback: skips animations if MediaQuery.disableAnimations
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ── Public API ───────────────────────────────────────────────────────────────

/// Describes which copy variant to show on the celebration screen.
enum LessonCelebrationVariant {
  /// Standard completion copy.
  regular,

  /// First lesson the user has ever completed.
  firstLesson,

  /// User is on a notable streak (pass [streakDays]).
  streakMilestone,

  /// User earned gems this lesson (pass [gemsEarned]).
  gemEarned,
}

/// Animated lesson-completion celebration overlay.
///
/// Wrap this in a [Stack] or show it via [LessonCelebrationOverlay.show] as an
/// [OverlayEntry] on top of the lesson screen content.
///
/// ```dart
/// LessonCelebrationOverlay.show(context, xpAmount: 40);
/// ```
class LessonCelebrationOverlay extends StatefulWidget {
  final int xpAmount;
  final LessonCelebrationVariant variant;

  /// Days on current streak — only relevant for [LessonCelebrationVariant.streakMilestone].
  final int streakDays;

  /// Gems earned this lesson — only relevant for [LessonCelebrationVariant.gemEarned].
  final int gemsEarned;

  /// Called when the user taps "Continue" (or after the auto-dismiss timer).
  final VoidCallback? onDismiss;

  const LessonCelebrationOverlay({
    super.key,
    required this.xpAmount,
    this.variant = LessonCelebrationVariant.regular,
    this.streakDays = 0,
    this.gemsEarned = 0,
    this.onDismiss,
  });

  /// Convenience: show as a full-screen overlay entry.
  static OverlayEntry show(
    BuildContext context, {
    required int xpAmount,
    LessonCelebrationVariant variant = LessonCelebrationVariant.regular,
    int streakDays = 0,
    int gemsEarned = 0,
    VoidCallback? onDismiss,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => LessonCelebrationOverlay(
        xpAmount: xpAmount,
        variant: variant,
        streakDays: streakDays,
        gemsEarned: gemsEarned,
        onDismiss: () {
          entry.remove();
          onDismiss?.call();
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    return entry;
  }

  @override
  State<LessonCelebrationOverlay> createState() =>
      _LessonCelebrationOverlayState();
}

class _LessonCelebrationOverlayState extends State<LessonCelebrationOverlay>
    with TickerProviderStateMixin {
  // Hero text: scale 0 → 1 with spring-like curve (~400ms)
  late AnimationController _heroCtrl;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;

  // Badge stagger: fade in after hero (+200ms delay)
  late AnimationController _badgeCtrl;
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;

  // XP counter: count-up with shimmer glow
  late AnimationController _xpCtrl;
  late Animation<int> _xpCount;
  late Animation<double> _xpGlow;

  // Bubble particles
  late AnimationController _bubbleCtrl;
  final List<_Bubble> _bubbles = [];
  final math.Random _rng = math.Random();

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.long1, // 400ms
    );
    _heroScale = CurvedAnimation(
      parent: _heroCtrl,
      curve: _SpringLikeCurve(),
    );
    _heroFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.long1,
    );
    _badgeFade = CurvedAnimation(
      parent: _badgeCtrl,
      curve: AppCurves.emphasized,
    );
    _badgeSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _badgeCtrl, curve: AppCurves.emphasized),
    );

    _xpCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.long2, // 500ms
    );
    _xpCount = IntTween(begin: 0, end: widget.xpAmount).animate(
      CurvedAnimation(
        parent: _xpCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _xpGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _xpCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    // Generate 4 bubbles with random horizontal positions & delays
    for (int i = 0; i < 4; i++) {
      _bubbles.add(
        _Bubble(
          x: 0.15 + _rng.nextDouble() * 0.7,
          delay: _rng.nextDouble() * 0.6,
          size: 6.0 + _rng.nextDouble() * 8.0,
          opacity: 0.15 + _rng.nextDouble() * 0.25,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;

    if (!_reduceMotion) {
      _heroCtrl.forward().then((_) {
        if (!mounted) return;
        Future.delayed(AppDurations.medium2, () {
          if (mounted) _badgeCtrl.forward();
        });
        _xpCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _badgeCtrl.dispose();
    _xpCtrl.dispose();
    _bubbleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = _CelebrationCopy.forVariant(
      widget.variant,
      streakDays: widget.streakDays,
      gemsEarned: widget.gemsEarned,
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent scrim
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),

          // Bubble particles
          if (!_reduceMotion) ..._buildBubbles(),

          // Main card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _buildCard(context, copy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _CelebrationCopy copy) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero text
          _buildHeroText(context, copy),

          const SizedBox(height: AppSpacing.lg2),

          // Badge / icon row
          _buildBadgeRow(context, copy),

          const SizedBox(height: AppSpacing.xl),

          // XP counter
          _buildXpCounter(context),

          // Optional gem bonus
          if (widget.variant == LessonCelebrationVariant.gemEarned &&
              widget.gemsEarned > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _buildGemBonus(context),
          ],

          const SizedBox(height: AppSpacing.xl),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.onDismiss,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero text ──────────────────────────────────────────────────────────────

  Widget _buildHeroText(BuildContext context, _CelebrationCopy copy) {
    final text = Text(
      copy.headline,
      style: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );

    if (_reduceMotion) return text;

    return AnimatedBuilder(
      animation: _heroCtrl,
      builder: (_, child) => FadeTransition(
        opacity: _heroFade,
        child: ScaleTransition(scale: _heroScale, child: child),
      ),
      child: text,
    );
  }

  // ── Badge / icon row ───────────────────────────────────────────────────────

  Widget _buildBadgeRow(BuildContext context, _CelebrationCopy copy) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BadgeChip(
          emoji: copy.badgeEmoji,
          label: copy.badgeLabel,
        ),
      ],
    );

    if (_reduceMotion) return row;

    return FadeTransition(
      opacity: _badgeFade,
      child: SlideTransition(position: _badgeSlide, child: row),
    );
  }

  // ── XP counter ─────────────────────────────────────────────────────────────

  Widget _buildXpCounter(BuildContext context) {
    if (_reduceMotion) {
      return _XpDisplay(xp: widget.xpAmount, glow: 1.0);
    }

    return AnimatedBuilder(
      animation: _xpCtrl,
      builder: (_, __) =>
          _XpDisplay(xp: _xpCount.value, glow: _xpGlow.value),
    );
  }

  // ── Gem bonus ──────────────────────────────────────────────────────────────

  Widget _buildGemBonus(BuildContext context) {
    if (_reduceMotion) {
      return _GemBonusRow(gems: widget.gemsEarned, opacity: 1.0);
    }

    return FadeTransition(
      opacity: _badgeFade,
      child: _GemBonusRow(gems: widget.gemsEarned, opacity: 1.0),
    );
  }

  // ── Bubble particles ───────────────────────────────────────────────────────

  List<Widget> _buildBubbles() {
    return _bubbles.map((b) {
      return AnimatedBuilder(
        animation: _bubbleCtrl,
        builder: (context, _) {
          final size = MediaQuery.of(context).size;
          // Phase offset per bubble (stagger the repeat loop)
          final phase = (_bubbleCtrl.value + b.delay) % 1.0;
          final y = size.height * (1.0 - phase); // rises from bottom to top
          final x = size.width * b.x;
          // Fade in/out at top and bottom edges
          final edgeFade = (math.sin(phase * math.pi)).clamp(0.0, 1.0);

          return Positioned(
            left: x - b.size / 2,
            top: y - b.size / 2,
            child: Opacity(
              opacity: b.opacity * edgeFade,
              child: Container(
                width: b.size,
                height: b.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _BadgeChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successAlpha10,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(
          color: AppColors.successAlpha30,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpDisplay extends StatelessWidget {
  final int xp;
  final double glow;

  const _XpDisplay({required this.xp, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg2,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3 * glow),
            blurRadius: 20 * glow,
            spreadRadius: 2 * glow,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+$xp XP',
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GemBonusRow extends StatelessWidget {
  final int gems;
  final double opacity;

  const _GemBonusRow({required this.gems, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💎', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+$gems gem${gems == 1 ? '' : 's'} earned',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.accentText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Copy variants ─────────────────────────────────────────────────────────────

class _CelebrationCopy {
  final String headline;
  final String badgeEmoji;
  final String badgeLabel;

  const _CelebrationCopy({
    required this.headline,
    required this.badgeEmoji,
    required this.badgeLabel,
  });

  static final _rng = math.Random();

  static _CelebrationCopy forVariant(
    LessonCelebrationVariant variant, {
    int streakDays = 0,
    int gemsEarned = 0,
  }) {
    switch (variant) {
      case LessonCelebrationVariant.firstLesson:
        return const _CelebrationCopy(
          headline: 'You did it — first lesson complete!',
          badgeEmoji: '🌱',
          badgeLabel: 'First lesson',
        );
      case LessonCelebrationVariant.streakMilestone:
        final headlines = [
          '$streakDays days in a row — you\'re unstoppable.',
          'A $streakDays-day streak — keep swimming!',
          '$streakDays lessons, $streakDays days. Respect.',
        ];
        return _CelebrationCopy(
          headline: headlines[_rng.nextInt(headlines.length)],
          badgeEmoji: '🔥',
          badgeLabel: '$streakDays-day streak',
        );
      case LessonCelebrationVariant.gemEarned:
        return _CelebrationCopy(
          headline: 'Lesson complete — and you earned gems!',
          badgeEmoji: '💎',
          badgeLabel: gemsEarned > 1 ? '$gemsEarned gems' : 'Gem earned',
        );
      case LessonCelebrationVariant.regular:
        final headlines = [
          'Lesson complete.',
          'Well done — another one down.',
          'Nice work. Keep going.',
          'That\'s the way. Lesson done.',
          'Your fish would be proud.',
        ];
        return _CelebrationCopy(
          headline: headlines[_rng.nextInt(headlines.length)],
          badgeEmoji: '✅',
          badgeLabel: 'Lesson complete',
        );
    }
  }
}

// ── Spring-like curve ─────────────────────────────────────────────────────────

/// A spring-like curve that overshoots slightly then settles.
/// Approximates a physical spring without needing a SpringSimulation.
class _SpringLikeCurve extends Curve {
  @override
  double transformInternal(double t) {
    // Approximation: easeOut with a gentle overshoot
    const overshoot = 0.08;
    if (t < 0.7) {
      // Accelerate fast to 1.0 + overshoot
      return (1.0 + overshoot) * Curves.easeOut.transform(t / 0.7);
    } else {
      // Settle back from overshoot
      final settle = (t - 0.7) / 0.3;
      return (1.0 + overshoot) - overshoot * Curves.easeOut.transform(settle);
    }
  }
}

// ── Bubble data ───────────────────────────────────────────────────────────────

class _Bubble {
  final double x; // Normalised 0–1 horizontal position
  final double delay; // Phase offset 0–1
  final double size; // Diameter in dp
  final double opacity;

  const _Bubble({
    required this.x,
    required this.delay,
    required this.size,
    required this.opacity,
  });
}
