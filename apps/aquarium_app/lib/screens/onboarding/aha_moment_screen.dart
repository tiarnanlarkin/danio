import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

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
  static const _warmCream = Color(0xFFFFF8F0);
  static const _amber = Color(0xFFF5A623); // Decorative amber — not for text
  static const _amberText = Color(0xFF9E6008); // WCAG AA text on light bg (4.8:1)

  // ── Phase tracking ──────────────────────────────────────────────
  int _phase = 1; // 1, 2, or 3
  bool _ctaTapped = false;

  // ── Phase 1 animations ──────────────────────────────────────────
  late final AnimationController _fishScaleCtrl;
  late final Animation<double> _fishScale;

  late final AnimationController _dotsCtrl; // looping dots
  int _dotCount = 1;

  // ── Phase 1→2 transition ───────────────────────────────────────
  late final AnimationController _transitionCtrl;
  late final Animation<double> _overlayOpacity;

  // ── Phase 2 card stagger ───────────────────────────────────────
  late final AnimationController _cardsCtrl;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  // ── Phase 3 fade ───────────────────────────────────────────────
  late final AnimationController _inviteCtrl;
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
    _fishScale = CurvedAnimation(
      parent: _fishScaleCtrl,
      curve: Curves.elasticOut,
    );

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
    _overlayOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOut),
    );

    // Phase 2 — 3 cards, staggered
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150), // 250ms × 3 + 300ms × 2 gap ≈ 1150
    );

    _cardFades = List.generate(3, (i) {
      final start = i * 0.26; // ~300 ms stagger at 1150 ms total
      final end = (start + 0.22).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _cardSlides = List.generate(3, (i) {
      final start = i * 0.26;
      final end = (start + 0.22).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(40, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    // Phase 3 — invite fade
    _inviteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _inviteFade = CurvedAnimation(parent: _inviteCtrl, curve: Curves.easeIn);

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
    _fishScaleCtrl.dispose();
    _dotsCtrl.dispose();
    _transitionCtrl.dispose();
    _cardsCtrl.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmCream,
      body: SafeArea(
        child: _phase == 1 ? _buildPhase1() : _buildPhase2And3(),
      ),
    );
  }

  // ─── PHASE 1 ─────────────────────────────────────────────────────

  Widget _buildPhase1() {
    final fishName = widget.selectedFish.commonName;

    return AnimatedBuilder(
      animation: _overlayOpacity,
      builder: (context, child) {
        return Container(
          color: Color.lerp(_warmCream, const Color(0xFFE8DFD3), _overlayOpacity.value),
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
                    color: _warmCream,
                    border: Border.all(color: _amber, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐠', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Fish name
              Text(
                fishName,
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Animated dots
              Text(
                'Building your $fishName care guide${'.' * _dotCount}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: _amberText,
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
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Your $fishName Profile',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _amberText,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm2),

              // Headline
              Text(
                '$fishName needs a little love.',
                style: GoogleFonts.lora(
                  fontSize: 24,
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
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      _motivationText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // CTA
                    Semantics(
                      button: true,
                      label: 'Start your journey',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _ctaTapped ? null : _onCtaTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _amber,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _amber.withAlpha(153),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _ctaTapped
                                ? '...'
                                : 'Start your journey →',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _warmCream,
            border: Border.all(color: _amber, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text('🐠', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: AppSpacing.sm2),
        Text(
          fishName,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
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
