import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../data/species_sprites.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 8 — Feature Summary
///
/// Shows users what Danio offers — all features available, no paywall.
/// Honest v1: no subscription, no trial, no fake pricing.
class FeatureSummaryScreen extends StatefulWidget {
  final SpeciesInfo selectedFish;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const FeatureSummaryScreen({
    super.key,
    required this.selectedFish,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<FeatureSummaryScreen> createState() => _FeatureSummaryScreenState();
}

class _FeatureSummaryScreenState extends State<FeatureSummaryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fishBounceController;
  late final CurvedAnimation _fishBounceCurve;
  late final Animation<double> _fishBounceAnim;

  @override
  void initState() {
    super.initState();

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    _fishBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fishBounceCurve = CurvedAnimation(parent: _fishBounceController, curve: Curves.easeInOut);
    _fishBounceAnim = Tween<double>(begin: 1.0, end: 1.05).animate(_fishBounceCurve);

    if (!disableAnimations) {
      _fishBounceController.forward();
    } else {
      _fishBounceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _fishBounceCurve.dispose();
    _fishBounceController.dispose();
    super.dispose();
  }

  void _onCtaTapped() {
    HapticFeedback.mediumImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg2),
                    // Fish reference header
                    _buildFishHeader(),
                    const SizedBox(height: AppSpacing.md),
                    // Title
                    Text(
                      'Everything you need, right here.',
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Danio is free to use — no subscription needed.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg2),
                    // Feature list
                    _buildFeatureList(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            // Bottom section: CTA
            _buildBottomSection(bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildFishHeader() {
    final spritePath = SpeciesSprites.thumbFor(widget.selectedFish.commonName);
    return Semantics(
      label:
          'Your ${widget.selectedFish.commonName} care guide is ready',
      child: AnimatedBuilder(
        animation: _fishBounceAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _fishBounceAnim.value,
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            spritePath != null
                ? Image.asset(
                    spritePath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    cacheWidth: 96,
                    cacheHeight: 96,
                  )
                : const Text('🐟', style: TextStyle(fontSize: 48)),
            const SizedBox(width: AppSpacing.sm2),
            Flexible(
              child: Text(
                'Your ${widget.selectedFish.commonName} care guide is ready.',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    const features = [
      'Full species care guides for 125+ fish (and growing)',
      'Water parameter tracking with smart alerts',
      'Tank compatibility checker',
      'Daily lessons to grow your fishkeeping skills',
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.onboardingAmber, size: 22),
                  const SizedBox(width: AppSpacing.sm2),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomSection(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, bottomPadding + AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.onboardingWarmCream,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: "Let's go! →",
            onPressed: _onCtaTapped,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            size: AppButtonSize.large,
            semanticsLabel: 'Continue to setup',
          ),
        ],
      ),
    );
  }
}
