import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 1 — Welcome / Hook
///
/// Full-bleed background illustration with headline, body copy, and CTA.
/// Communicates via [onNext] (start onboarding) and optional [onLogin].
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onLogin;

  const WelcomeScreen({
    super.key,
    required this.onNext,
    this.onLogin,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late final AnimationController _headlineController;
  late final AnimationController _bodyController;
  late final AnimationController _buttonController;

  late final CurvedAnimation _headlineOpacityCurve;
  late final Animation<double> _headlineOpacity;
  late final CurvedAnimation _headlineSlideCurve;
  late final Animation<Offset> _headlineSlide;
  late final CurvedAnimation _bodyOpacityCurve;
  late final Animation<double> _bodyOpacity;
  late final CurvedAnimation _buttonOpacityCurve;
  late final Animation<double> _buttonOpacity;
  late final CurvedAnimation _buttonSlideCurve;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // Headline: fade + slide up (300ms)
    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headlineOpacityCurve = CurvedAnimation(
      parent: _headlineController,
      curve: AppCurves.standardDecelerate,
    );
    _headlineOpacity = _headlineOpacityCurve;
    _headlineSlideCurve = CurvedAnimation(
      parent: _headlineController,
      curve: AppCurves.standardDecelerate,
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_headlineSlideCurve);

    // Body: fade in (300ms), starts 150ms after headline
    _bodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bodyOpacityCurve = CurvedAnimation(
      parent: _bodyController,
      curve: AppCurves.standardDecelerate,
    );
    _bodyOpacity = _bodyOpacityCurve;

    // Button: slide up + fade (200ms spring), starts after body
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonOpacityCurve = CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.standardDecelerate,
    );
    _buttonOpacity = _buttonOpacityCurve;
    _buttonSlideCurve = CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.elastic,
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_buttonSlideCurve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimations();
  }

  void _startAnimations() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _headlineController.value = 1.0;
      _bodyController.value = 1.0;
      _buttonController.value = 1.0;
      return;
    }

    _headlineController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _bodyController.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _headlineOpacityCurve.dispose();
    _headlineSlideCurve.dispose();
    _headlineController.dispose();
    _bodyOpacityCurve.dispose();
    _bodyController.dispose();
    _buttonOpacityCurve.dispose();
    _buttonSlideCurve.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background image
          ExcludeSemantics(
            child: Image.asset(
              'assets/images/onboarding/onboarding_journey_bg.webp',
              fit: BoxFit.cover,
              cacheWidth: 800,
              cacheHeight: 1600,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Gradient scrim over lower portion
          Positioned.fill(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 0.65, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.blackAlpha30,
                      AppColors.blackAlpha80,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content in lower portion
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: bottomPadding + AppSpacing.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Headline
                SlideTransition(
                  position: _headlineSlide,
                  child: FadeTransition(
                    opacity: _headlineOpacity,
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Your fish deserve better than guesswork.',
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingWarmCream,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm2),

                // Body
                FadeTransition(
                  opacity: _bodyOpacity,
                  child: Text(
                    "Danio learns what's in your tank and tells you exactly what they need.",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onboardingWarmCream.withAlpha(204), // 80%
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // CTA Button
                SlideTransition(
                  position: _buttonSlide,
                  child: FadeTransition(
                    opacity: _buttonOpacity,
                    child: AppButton(
                      label: "Let's get started →",
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onNext();
                      },
                      variant: AppButtonVariant.primary,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      semanticsLabel: "Let's get started",
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Secondary link
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      widget.onLogin?.call();
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      'Skip setup, I\'ll explore first',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onboardingWarmCream.withAlpha(217), // 85%
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.onboardingWarmCream.withAlpha(128),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
