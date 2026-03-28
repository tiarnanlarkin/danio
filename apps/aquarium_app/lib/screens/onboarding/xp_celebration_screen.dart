import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 5 — First XP Earned (Celebration)
///
/// Rewards the user with +10 XP for completing the micro-lesson.
/// Features confetti burst, XP badge pop, and progress bar fill.
///
/// Communicates completion via [onNext].
class XpCelebrationScreen extends StatefulWidget {
  final VoidCallback onNext;

  const XpCelebrationScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<XpCelebrationScreen> createState() => _XpCelebrationScreenState();
}

class _XpCelebrationScreenState extends State<XpCelebrationScreen>
    with TickerProviderStateMixin {

  late final AnimationController _confettiController;
  late final AnimationController _badgeController;
  late final AnimationController _progressController;
  late final AnimationController _textController;
  late final AnimationController _buttonController;

  late final CurvedAnimation _badgeScaleCurve;
  late final Animation<double> _badgeScale;
  late final CurvedAnimation _progressValueCurve;
  late final Animation<double> _progressValue;
  late final CurvedAnimation _textOpacityCurve;
  late final Animation<double> _textOpacity;
  late final CurvedAnimation _buttonOpacityCurve;
  late final Animation<double> _buttonOpacity;
  late final CurvedAnimation _buttonSlideCurve;
  late final Animation<Offset> _buttonSlide;

  late final List<_ConfettiParticle> _particles;
  final _random = Random();
  bool _sequenceStarted = false;

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    _particles = List.generate(30, (_) => _ConfettiParticle(_random));

    // Confetti burst (800ms)
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Badge pop (400ms, spring)
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _badgeScaleCurve = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack, // Overshoots to ~1.15 then settles — same spring feel
    );
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(_badgeScaleCurve);

    // Progress bar (600ms ease-out)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressValueCurve = CurvedAnimation(
      parent: _progressController,
      curve: AppCurves.standardDecelerate,
    );
    _progressValue = Tween<double>(begin: 0, end: 0.1).animate(_progressValueCurve);

    // Text fade
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _textOpacityCurve = CurvedAnimation(
      parent: _textController,
      curve: AppCurves.standardDecelerate,
    );
    _textOpacity = _textOpacityCurve;

    // Button slide + fade
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonOpacityCurve = CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.standardDecelerate,
    );
    _buttonOpacity = _buttonOpacityCurve;
    _buttonSlideCurve = CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.standardDecelerate,
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_buttonSlideCurve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startSequence();
  }

  void _startSequence() {
    if (_sequenceStarted) return;
    _sequenceStarted = true;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _confettiController.value = 1.0;
      _badgeController.value = 1.0;
      _progressController.value = 1.0;
      _textController.value = 1.0;
      _buttonController.value = 1.0;
      return;
    }

    HapticFeedback.heavyImpact();

    // Sequence per spec:
    // 1. Confetti burst starts
    // 2. Badge appears 100ms after confetti
    // 3. Progress bar fills 300ms after badge
    // 4. Text fades in 200ms after progress bar
    // 5. Button slides up 200ms after text

    _confettiController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _badgeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _badgeScaleCurve.dispose();
    _badgeController.dispose();
    _progressValueCurve.dispose();
    _progressController.dispose();
    _textOpacityCurve.dispose();
    _textController.dispose();
    _buttonOpacityCurve.dispose();
    _buttonSlideCurve.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti layer
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // XP Badge
                  ScaleTransition(
                    scale: _badgeScale,
                    child: Semantics(
                      label: 'Plus 10 experience points earned',
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onboardingAmber,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onboardingAmber.withAlpha(102), // 40%
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+10 XP',
                          style: GoogleFonts.lora(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onboardingWarmCream,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Level context
                  FadeTransition(
                    opacity: _textOpacity,
                    child: ExcludeSemantics(
                      child: Text(
                        'Level 1 · 10 XP',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm2),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressValue,
                    builder: (context, _) {
                      return Semantics(
                        label:
                            'Experience progress: ${(_progressValue.value * 100).round()} percent',
                        child: Container(
                          height: 8,
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressValue.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.onboardingAmber,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Achievement label
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Semantics(
                      header: true,
                      child: Text(
                        'First lesson complete 🎣',
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm2),

                  // Body text
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      "You just earned your first 10 XP. Now let's make it personal — tell us what fish you're keeping.",
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CTA Button
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: Semantics(
                        button: true,
                        label: 'Add my fish',
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              widget.onNext();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onboardingAmber,
                              foregroundColor: const Color(0xFF2D3436),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              textStyle: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Add my fish →'),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti system
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double angle; // radians, direction from centre
  final double speed; // pixels per unit progress
  final double size; // circle radius
  final Color color;

  _ConfettiParticle(Random r)
      : angle = r.nextDouble() * 2 * pi,
        speed = 80 + r.nextDouble() * 200,
        size = 3 + r.nextDouble() * 5,
        color = _confettiColors[r.nextInt(_confettiColors.length)];

  static const _confettiColors = [
    AppColors.onboardingAmber, // amber
    Color(0xFFE8934A), // warm orange
    AppColors.onboardingWarmCream, // cream
    Color(0xFFD4A574), // soft gold
    Color(0xFFFFD54F), // golden yellow
  ];
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height * 0.35);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final dx = cos(p.angle) * p.speed * progress;
      final dy = sin(p.angle) * p.speed * progress +
          (50 * progress * progress); // gravity
      final pos = center + Offset(dx, dy);

      final paint = Paint()
        ..color = p.color.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, p.size * (1.0 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
