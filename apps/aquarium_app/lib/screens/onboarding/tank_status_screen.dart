import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Screen 3 — Tank Status
///
/// Three tap-to-select cards collecting the user's current tank situation.
/// Communicates the chosen status string via [onSelected].
/// Values: 'planning' | 'cycling' | 'active'
class TankStatusScreen extends StatefulWidget {
  final ValueChanged<String> onSelected;

  const TankStatusScreen({
    super.key,
    required this.onSelected,
  });

  @override
  State<TankStatusScreen> createState() => _TankStatusScreenState();
}

class _TankStatusScreenState extends State<TankStatusScreen>
    with TickerProviderStateMixin {
  static const _warmCream = Color(0xFFFFF8F0);
  static const _onboardingAmber = Color(0xFFF5A623);

  String? _selected;

  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _cardOpacities;
  late final List<Animation<Offset>> _cardSlides;

  AnimationController? _pulseController;
  Animation<double>? _pulseScale;

  static const _cards = [
    _CardData(
      emoji: '🏠',
      label: 'Thinking about getting one',
      description: "I'm planning my first tank but haven't set it up yet",
      value: 'planning',
    ),
    _CardData(
      emoji: '🔧',
      label: 'Setting it up',
      description: 'My tank is new or still cycling',
      value: 'cycling',
    ),
    _CardData(
      emoji: '🐟',
      label: 'Already up and running',
      description: 'I have fish in my tank right now',
      value: 'active',
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

    _cardOpacities = _cardControllers.map((c) {
      return CurvedAnimation(parent: c, curve: AppCurves.standardDecelerate);
    }).toList();

    _cardSlides = _cardControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: AppCurves.standardDecelerate));
    }).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.02), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: AppCurves.standard,
    ));
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
    for (final c in _cardControllers) {
      c.dispose();
    }
    _pulseController?.dispose();
    super.dispose();
  }

  void _selectCard(String value) {
    HapticFeedback.lightImpact();
    setState(() => _selected = value);

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _pulseController?.reset();
      _pulseController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Progress dots — dot 2 filled
              _ProgressDots(currentIndex: 1),

              const SizedBox(height: AppSpacing.xl),

              // Headline
              Semantics(
                header: true,
                child: Text(
                  "What's your tank situation?",
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
                "We'll help you from wherever you are right now.",
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
                    final isSelected = _selected == card.value;

                    Widget cardWidget = _OptionCard(
                      emoji: card.emoji,
                      label: card.label,
                      description: card.description,
                      isSelected: isSelected,
                      onTap: () => _selectCard(card.value),
                    );

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
                          _selected != null ? _onboardingAmber : Colors.grey[300],
                      foregroundColor: _selected != null
                          ? const Color(0xFF2D3436)
                          : Colors.grey[500],
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
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
  final String value;

  const _CardData({
    required this.emoji,
    required this.label,
    required this.description,
    required this.value,
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

  static const _onboardingAmber = Color(0xFFF5A623);

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
                ? _onboardingAmber.withAlpha(26)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? _onboardingAmber : AppColors.border,
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

class _ProgressDots extends StatelessWidget {
  final int currentIndex;

  const _ProgressDots({required this.currentIndex});

  static const _onboardingAmber = Color(0xFFF5A623);

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
              color: isFilled ? _onboardingAmber : AppColors.border,
            ),
          );
        }),
      ),
    );
  }
}
