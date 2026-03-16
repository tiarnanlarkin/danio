import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

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
  static const _warmCream = Color(0xFFFFF8F0);
  static const _onboardingAmber = Color(0xFFF5A623);

  late final AnimationController _headlineController;
  late final AnimationController _bodyController;
  late final AnimationController _buttonController;

  late final Animation<double> _headlineOpacity;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _bodyOpacity;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // Headline: fade + slide up (300ms)
    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headlineOpacity = CurvedAnimation(
      parent: _headlineController,
      curve: AppCurves.standardDecelerate,
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headlineController,
      curve: AppCurves.standardDecelerate,
    ));

    // Body: fade in (300ms), starts 150ms after headline
    _bodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bodyOpacity = CurvedAnimation(
      parent: _bodyController,
      curve: AppCurves.standardDecelerate,
    );

    // Button: slide up + fade (200ms spring), starts after body
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.standardDecelerate,
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: AppCurves.elastic,
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
    _headlineController.dispose();
    _bodyController.dispose();
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
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2D3436),
              ),
            ),
          ),

          // Gradient scrim over lower portion
          ExcludeSemantics(
            child: Positioned.fill(
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
                        style: GoogleFonts.lora(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _warmCream,
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
                      color: _warmCream.withAlpha(204), // 80%
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
                    child: Semantics(
                      button: true,
                      label: 'Let\'s get started',
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onNext();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onboardingAmber,
                            foregroundColor: const Color(0xFF2D3436),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            textStyle: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Let\'s get started →'),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Secondary link
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: Semantics(
                    button: true,
                    label: 'I already have an account',
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onLogin?.call();
                      },
                      child: Text(
                        'I already have an account',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _warmCream.withAlpha(178), // 70%
                          decoration: TextDecoration.underline,
                          decorationColor: _warmCream.withAlpha(128),
                        ),
                        textAlign: TextAlign.center,
                      ),
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
