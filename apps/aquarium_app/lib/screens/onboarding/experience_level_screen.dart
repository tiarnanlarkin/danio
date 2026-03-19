import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

/// Screen 2 — Experience Level
///
/// Three tap-to-select cards collecting the user's fishkeeping experience.
/// Communicates the chosen [ExperienceLevel] via [onSelected].
class ExperienceLevelScreen extends StatefulWidget {
  final ValueChanged<ExperienceLevel> onSelected;

  const ExperienceLevelScreen({
    super.key,
    required this.onSelected,
  });

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen>
    with TickerProviderStateMixin {

  ExperienceLevel? _selected;

  late final List<AnimationController> _cardControllers;
  late final List<CurvedAnimation> _cardOpacitiesCurves;
  late final List<Animation<double>> _cardOpacities;
  late final List<CurvedAnimation> _cardSlidesCurves;
  late final List<Animation<Offset>> _cardSlides;

  AnimationController? _pulseController;
  CurvedAnimation? _pulseCurve;
  Animation<double>? _pulseScale;

  static const _cards = [
    _CardData(
      emoji: '🐠',
      label: 'Just starting out',
      description: "I'm new to fishkeeping or setting up my first tank",
      level: ExperienceLevel.beginner,
    ),
    _CardData(
      emoji: '🐡',
      label: 'A few years in',
      description: "I've kept fish before and know the basics",
      level: ExperienceLevel.intermediate,
    ),
    _CardData(
      emoji: '🦈',
      label: 'Pretty experienced',
      description: "I've had multiple tanks or kept challenging species",
      level: ExperienceLevel.expert,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _cardControllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });

    _cardOpacitiesCurves = _cardControllers.map((c) {
      return CurvedAnimation(parent: c, curve: AppCurves.standardDecelerate);
    }).toList();

    _cardOpacities = _cardOpacitiesCurves.map((curve) {
      return curve;
    }).toList();

    _cardSlidesCurves = _cardControllers.map((c) {
      return CurvedAnimation(parent: c, curve: AppCurves.standardDecelerate);
    }).toList();

    _cardSlides = _cardSlidesCurves.map((curve) {
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(curve);
    }).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseCurve = CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.02).animate(_pulseCurve!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimations();
  }

  void _startAnimations() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      for (final c in _cardControllers) {
        c.value = 1.0;
      }
      return;
    }

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _cardOpacitiesCurves) { c.dispose(); }
    for (final c in _cardSlidesCurves) { c.dispose(); }
    for (final c in _cardControllers) {
      c.dispose();
    }
    _pulseCurve?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _selectCard(ExperienceLevel level) {
    HapticFeedback.lightImpact();
    setState(() => _selected = level);

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _pulseController?.reset();
      _pulseController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Progress dots
              _ProgressDots(currentIndex: 0),

              const SizedBox(height: AppSpacing.xl),

              // Headline
              Semantics(
                header: true,
                child: Text(
                  'How long have you kept fish?',
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                "We'll adjust what we show you based on your experience.",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Cards
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _cards.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm2),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isSelected = _selected == card.level;

                    Widget cardWidget = _OptionCard(
                      emoji: card.emoji,
                      label: card.label,
                      description: card.description,
                      isSelected: isSelected,
                      onTap: () => _selectCard(card.level),
                    );

                    // Apply pulse scale to selected card
                    if (isSelected && _pulseScale != null) {
                      cardWidget = ScaleTransition(
                        scale: _pulseScale!,
                        child: cardWidget,
                      );
                    }

                    return SlideTransition(
                      position: _cardSlides[index],
                      child: FadeTransition(
                        opacity: _cardOpacities[index],
                        child: cardWidget,
                      ),
                    );
                  },
                ),
              ),

              // Continue button
              Semantics(
                button: true,
                enabled: _selected != null,
                label: 'Continue',
                child: AnimatedContainer(
                  duration: AppDurations.medium1,
                  curve: AppCurves.standard,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selected != null
                        ? () {
                            HapticFeedback.mediumImpact();
                            widget.onSelected(_selected!);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selected != null ? AppColors.onboardingAmber : AppColors.border,
                      foregroundColor: _selected != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.textSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      textStyle: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CardData {
  final String emoji;
  final String label;
  final String description;
  final ExperienceLevel level;

  const _CardData({
    required this.emoji,
    required this.label,
    required this.description,
    required this.level,
  });
}

class _OptionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label. $description',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium1,
          curve: AppCurves.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.onboardingAmber.withAlpha(26) // ~10%
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.onboardingAmber : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
}

/// Reusable 3-dot progress indicator for onboarding screens.
class _ProgressDots extends StatelessWidget {
  final int currentIndex;

  const _ProgressDots({required this.currentIndex});


  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${currentIndex + 1} of 3',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isFilled = i <= currentIndex;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? AppColors.onboardingAmber : AppColors.border,
            ),
          );
        }),
      ),
    );
  }
}
