import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/species_database.dart';
import '../../data/species_sprites.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 7 — Personalised Fish Care Reveal (THE AHA MOMENT)
///
/// Three-phase reveal:
///   Phase 1 — "Generating your profile…"   (theatrical delay, ~2 s)
///   Phase 2 — Care-card cascade            (~2 s)
///   Phase 3 — The invite / CTA
///
/// All automatic. No user input until the CTA at the end.
class AhaMomentScreen extends StatefulWidget {
  final SpeciesInfo selectedFish;
  final ExperienceLevel experienceLevel;
  final String tankStatus; // 'active' | 'planning' | 'cycling'
  final VoidCallback onComplete;

  const AhaMomentScreen({
    super.key,
    required this.selectedFish,
    required this.experienceLevel,
    required this.tankStatus,
    required this.onComplete,
  });

  @override
  State<AhaMomentScreen> createState() => _AhaMomentScreenState();
}

class _AhaMomentScreenState extends State<AhaMomentScreen>
    with TickerProviderStateMixin {
  // ── Colours ──────────────────────────────────────────────────────
  // Onboarding colours consolidated into AppColors

  // ── Phase tracking ──────────────────────────────────────────────
  int _phase = 1; // 1, 2, or 3
  bool _ctaTapped = false;

  // ── Phase 1 animations ──────────────────────────────────────────
  late final AnimationController _fishScaleCtrl;
  late final CurvedAnimation _fishScaleCurve;
  late final Animation<double> _fishScale;

  late final AnimationController _dotsCtrl; // looping dots
  int _dotCount = 1;

  // ── Phase 1→2 transition ───────────────────────────────────────
  late final AnimationController _transitionCtrl;
  late final CurvedAnimation _transitionCurve;
  late final Animation<double> _overlayOpacity;

  // ── Phase 2 card stagger ───────────────────────────────────────
  late final AnimationController _cardsCtrl;
  late final List<CurvedAnimation> _cardFadeCurves;
  late final List<Animation<double>> _cardFades;
  late final List<CurvedAnimation> _cardSlideCurves;
  late final List<Animation<Offset>> _cardSlides;

  // ── Phase 3 fade ───────────────────────────────────────────────
  late final AnimationController _inviteCtrl;
  late final CurvedAnimation _inviteFadeCurve;
  late final Animation<double> _inviteFade;

  bool get _reduceMotion =>
      MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();

    // Phase 1 — fish emoji scale-up (spring, 400 ms)
    _fishScaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fishScaleCurve = CurvedAnimation(
      parent: _fishScaleCtrl,
      curve: Curves.elasticOut,
    );
    _fishScale = _fishScaleCurve;

    // Phase 1 — animated dots loop
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        final newCount = ((_dotsCtrl.value * 3).floor() % 3) + 1;
        if (newCount != _dotCount) {
          setState(() => _dotCount = newCount);
        }
      });

    // Phase 1→2 transition (400 ms)
    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _transitionCurve = CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOut);
    _overlayOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(_transitionCurve);

    // Phase 2 — 3 cards, staggered
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150), // 250ms × 3 + 300ms × 2 gap ≈ 1150
    );

    _cardFadeCurves = List.generate(3, (i) {
      final start = i * 0.26; // ~300 ms stagger at 1150 ms total
      final end = (start + 0.22).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _cardsCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _cardFades = _cardFadeCurves.map((curve) {
      return Tween<double>(begin: 0, end: 1).animate(curve);
    }).toList();

    _cardSlideCurves = List.generate(3, (i) {
      final start = i * 0.26;
      final end = (start + 0.22).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _cardsCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _cardSlides = _cardSlideCurves.map((curve) {
      return Tween<Offset>(
        begin: const Offset(40, 0),
        end: Offset.zero,
      ).animate(curve);
    }).toList();

    // Phase 3 — invite fade
    _inviteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _inviteFadeCurve = CurvedAnimation(parent: _inviteCtrl, curve: Curves.easeIn);
    _inviteFade = _inviteFadeCurve;

    // Start the sequence
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
  }

  Future<void> _startSequence() async {
    if (_reduceMotion) {
      // Skip all animation — go straight to phase 3 with everything visible
      setState(() => _phase = 3);
      _fishScaleCtrl.value = 1;
      _transitionCtrl.value = 1;
      _cardsCtrl.value = 1;
      _inviteCtrl.value = 1;
      return;
    }

    // Phase 1 — theatrical delay
    _fishScaleCtrl.forward();
    _dotsCtrl.repeat();
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    // Transition to phase 2
    _dotsCtrl.stop();
    setState(() => _phase = 2);
    await _transitionCtrl.forward();

    // Phase 2 — card cascade
    await _cardsCtrl.forward();

    // Phase 3
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() => _phase = 3);
    _inviteCtrl.forward();
  }

  void _onCtaTap() {
    if (_ctaTapped) return;
    HapticFeedback.mediumImpact();
    setState(() => _ctaTapped = true);

    // 2-second silent beat, then complete
    Future<void>.delayed(const Duration(seconds: 2), widget.onComplete);
  }

  @override
  void dispose() {
    _fishScaleCurve.dispose();
    _fishScaleCtrl.dispose();
    _dotsCtrl.dispose();
    _transitionCurve.dispose();
    _transitionCtrl.dispose();
    for (final c in _cardFadeCurves) { c.dispose(); }
    for (final c in _cardSlideCurves) { c.dispose(); }
    _cardsCtrl.dispose();
    _inviteFadeCurve.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: _phase == 1 ? _buildPhase1() : _buildPhase2And3(),
      ),
    );
  }

  // ─── PHASE 1 ─────────────────────────────────────────────────────

  Widget _buildPhase1() {
    final fishName = widget.selectedFish.commonName;
    final spritePath = SpeciesSprites.thumbFor(fishName);

    return AnimatedBuilder(
      animation: _overlayOpacity,
      builder: (context, child) {
        return Container(
          color: Color.lerp(AppColors.onboardingWarmCream, const Color(0xFFE8DFD3), _overlayOpacity.value),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fish circle with amber ring
              ScaleTransition(
                scale: _fishScale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.onboardingWarmCream,
                    border: Border.all(color: AppColors.onboardingAmber, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: spritePath != null
                      ? ClipOval(
                          child: Image.asset(
                            spritePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            cacheWidth: 160,
                            cacheHeight: 160,
                            semanticLabel: fishName,
                          ),
                        )
                      : const Text('🐠', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Fish name
              Text(
                fishName,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Animated dots
              Text(
                'Building your $fishName care guide${'.' * _dotCount}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onboardingAmberText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── PHASE 2 + 3 ────────────────────────────────────────────────

  Widget _buildPhase2And3() {
    final fish = widget.selectedFish;
    final fishName = fish.commonName;

    return AnimatedBuilder(
      animation: Listenable.merge([_transitionCtrl, _cardsCtrl, _inviteCtrl]),
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-left fish marker
              _buildFishMarker(fishName),

              const SizedBox(height: AppSpacing.md),

              // Amber header pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm4,
                  vertical: AppSpacing.xs2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onboardingAmber.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.lg2),
                ),
                child: Text(
                  'Your $fishName Profile',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingAmberText,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm2),

              // Headline
              Text(
                '$fishName needs a little love.',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Care cards
              _buildCareCard(
                index: 0,
                emoji: '💧',
                label: 'Ideal pH',
                value: '${fish.minPh}–${fish.maxPh}',
                subLabel: _phSubLabel(fish),
              ),
              const SizedBox(height: AppSpacing.sm2),
              _buildCareCard(
                index: 1,
                emoji: '🐠',
                label: 'Tank mates',
                value: fish.temperament,
                subLabel: _compatSubLabel(fish),
              ),
              const SizedBox(height: AppSpacing.sm2),
              _buildCareCard(
                index: 2,
                emoji: '⭐',
                label: 'Care level',
                value: _careLevelValue(fish),
                subLabel: _careLevelSubLabel(fish),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Phase 3 — invite + CTA
              FadeTransition(
                opacity: _inviteFade,
                child: Column(
                  children: [
                    Text(
                      _inviteText,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      _motivationText,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // CTA
                    AppButton(
                      label: _ctaTapped ? '...' : 'Start your journey →',
                      onPressed: _ctaTapped ? null : _onCtaTap,
                      variant: AppButtonVariant.primary,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      semanticsLabel: 'Start your journey',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  Widget _buildFishMarker(String fishName) {
    final spritePath = SpeciesSprites.thumbFor(fishName);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.onboardingWarmCream,
            border: Border.all(color: AppColors.onboardingAmber, width: 2),
          ),
          alignment: Alignment.center,
          child: spritePath != null
              ? ClipOval(
                  child: Image.asset(
                    spritePath,
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    cacheWidth: 68,
                    cacheHeight: 68,
                    semanticLabel: fishName,
                  ),
                )
              : const Text('🐠', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: AppSpacing.sm2),
        Text(
          fishName,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCareCard({
    required int index,
    required String emoji,
    required String label,
    required String value,
    required String subLabel,
  }) {
    return AnimatedBuilder(
      animation: _cardsCtrl,
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlides[index].value,
          child: Opacity(
            opacity: _cardFades[index].value,
            child: child,
          ),
        );
      },
      child: Semantics(
        label: '$label: $value. $subLabel',
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(AppRadius.sm4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.sm2),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Copy helpers ────────────────────────────────────────────────

  String _phSubLabel(SpeciesInfo fish) {
    final range = fish.maxPh - fish.minPh;
    if (fish.maxPh <= 7.0) {
      return 'Soft, slightly acidic water. Most tap water is too alkaline — we\'ll show you how to adjust.';
    } else if (fish.minPh >= 7.0) {
      return 'Alkaline water preferred. Good news: most tap water is already close.';
    } else if (range > 2) {
      return 'Adaptable to a wide pH range. Great for community tanks.';
    }
    return 'Most tap water is 7.2–7.8 — we\'ll show you if adjustment is needed.';
  }

  String _compatSubLabel(SpeciesInfo fish) {
    if (fish.avoidWith.isNotEmpty) {
      final avoid = fish.avoidWith.take(3).join(', ');
      return 'Avoid: $avoid.';
    }
    if (fish.temperament.toLowerCase() == 'aggressive') {
      return 'Best kept as the dominant species — choose tank mates carefully.';
    }
    return 'Compatible with most peaceful community fish.';
  }

  String _careLevelValue(SpeciesInfo fish) {
    switch (fish.careLevel.toLowerCase()) {
      case 'beginner':
        return 'Easy — great choice for beginners';
      case 'intermediate':
        return 'Moderate — needs some attention';
      case 'advanced':
        return 'Challenging — for experienced keepers';
      default:
        return fish.careLevel;
    }
  }

  String _careLevelSubLabel(SpeciesInfo fish) {
    if (fish.minSchoolSize > 1) {
      return 'Best kept in groups of ${fish.minSchoolSize}+ or they\'ll stress and hide.';
    }
    return 'Can be kept singly. Watch for territorial behaviour.';
  }

  String get _inviteText =>
      'Danio tracks all of this for you — and alerts you if anything goes wrong.';

  String get _motivationText {
    final isPlanning =
        widget.tankStatus == 'planning' || widget.tankStatus == 'cycling';

    switch (widget.experienceLevel) {
      case ExperienceLevel.beginner:
        return isPlanning
            ? 'Danio will help you get it right from day one.'
            : 'Danio will help you keep them alive — and thriving.';
      case ExperienceLevel.intermediate:
        return isPlanning
            ? 'Danio will watch your parameters when your tank is ready.'
            : 'Danio will watch your parameters and flag anything unusual.';
      case ExperienceLevel.expert:
        return isPlanning
            ? 'Danio tracks everything, so you can plan the fun parts.'
            : 'Danio tracks everything, so you can focus on the fun parts.';
    }
  }
}
