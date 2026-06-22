import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/species_database.dart';
import '../../data/species_sprites.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import 'onboarding_layout.dart';

/// Screen 8 — Feature Summary
///
/// Shows users what Danio offers in the local build.
/// Honest v1: no paid gate, fake monetization copy, or disabled CTA.
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
  bool _ctaTapped = false;

  @override
  void initState() {
    super.initState();

    final disableAnimations = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    _fishBounceController = AnimationController(
      vsync: this,
      duration: AppDurations.medium4,
    );
    _fishBounceCurve = CurvedAnimation(
      parent: _fishBounceController,
      curve: Curves.easeInOut,
    );
    _fishBounceAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(_fishBounceCurve);

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
    if (_ctaTapped) return;
    _ctaTapped = true;
    HapticFeedback.mediumImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onCtaTapped,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: OnboardingContentFrame(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg2),
                        // Fish reference header
                        _buildFishHeader(),
                        const SizedBox(height: AppSpacing.md),
                        // Title
                        Text(
                          'Everything you need, right here.',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Danio is free to use. No subscription needed.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
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
              ),
              // Bottom section: CTA
              _buildBottomSection(bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFishHeader() {
    final spritePath = SpeciesSprites.thumbFor(widget.selectedFish.commonName);
    return Semantics(
      label: 'Your ${widget.selectedFish.commonName} care guide is ready',
      child: AnimatedBuilder(
        animation: _fishBounceAnim,
        builder: (context, child) {
          return Transform.scale(scale: _fishBounceAnim.value, child: child);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            spritePath != null
                ? ExcludeSemantics(
                    child: Image.asset(
                      spritePath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      cacheWidth: 96,
                      cacheHeight: 96,
                    ),
                  )
                : const Icon(
                    Icons.set_meal_outlined,
                    color: AppColors.onboardingAmberText,
                    size: 48,
                  ),
            const SizedBox(width: AppSpacing.sm2),
            Flexible(
              child: Text(
                'Your ${widget.selectedFish.commonName} care guide is ready.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
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
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.onboardingAmber,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm2),
                  Expanded(
                    child: Text(
                      f,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomPadding + AppSpacing.md,
      ),
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
          OnboardingContentFrame(
            padding: EdgeInsets.zero,
            child: AppButton(
              label: "Let's go! →",
              onPressed: _onCtaTapped,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              size: AppButtonSize.large,
              semanticsLabel: 'Continue to setup',
            ),
          ),
        ],
      ),
    );
  }
}
