import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../theme/app_theme.dart';

/// Screen 8 — Paywall Stub
///
/// Production-quality paywall UI shown immediately after the aha moment.
/// Currently a stub: tapping CTA shows a SnackBar and advances.
/// No billing backend yet.
class PaywallStubScreen extends StatefulWidget {
  final SpeciesInfo selectedFish;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const PaywallStubScreen({
    super.key,
    required this.selectedFish,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<PaywallStubScreen> createState() => _PaywallStubScreenState();
}

class _PaywallStubScreenState extends State<PaywallStubScreen>
    with TickerProviderStateMixin {
  // Amber brand colour from spec

  late final AnimationController _fishBounceController;
  late final Animation<double> _fishBounceAnim;

  late final AnimationController _maybeLaterController;
  late final Animation<double> _maybeLaterOpacity;

  int _selectedPlan = 0; // 0 = annual (default)

  @override
  void initState() {
    super.initState();

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    // Fish header bounce: scale 1.0 → 1.05 → 1.0 over 300ms
    _fishBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fishBounceAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _fishBounceController, curve: Curves.easeInOut),
    );

    // "Maybe later" fades in 1s after build
    _maybeLaterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _maybeLaterOpacity = CurvedAnimation(
      parent: _maybeLaterController,
      curve: Curves.easeIn,
    );

    if (!disableAnimations) {
      _fishBounceController.forward();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _maybeLaterController.forward();
      });
    } else {
      _fishBounceController.value = 1.0;
      _maybeLaterController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _fishBounceController.dispose();
    _maybeLaterController.dispose();
    super.dispose();
  }

  void _onCtaTapped() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscription coming soon! Enjoy Danio free for now.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    // Advance after snackbar is visible
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onComplete();
    });
  }

  void _onSkipTapped() {
    HapticFeedback.lightImpact();
    widget.onSkip();
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Fish reference header
                    _buildFishHeader(),
                    const SizedBox(height: 24),
                    // Paywall title
                    Text(
                      'Keep your fish alive, longer.',
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // Feature list
                    _buildFeatureList(),
                    const SizedBox(height: 28),
                    // Pricing block
                    _buildPricingBlock(),
                    const SizedBox(height: 20),
                    // Trial pill
                    _buildTrialPill(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom section: CTA + Maybe later + Legal
            _buildBottomSection(bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildFishHeader() {
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
            const Text('🐟', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 12),
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
      'Full species care guides for 2,000+ fish',
      'Water parameter tracking with smart alerts',
      'Tank compatibility checker',
      'Daily lessons to grow your fishkeeping skills',
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.onboardingAmber, size: 22),
                  const SizedBox(width: 12),
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

  Widget _buildPricingBlock() {
    return Column(
      children: [
        // Annual plan — pre-selected
        _buildPlanTile(
          index: 0,
          price: '£1.67/month',
          subtitle: 'Billed as £19.99/year',
          badge: 'MOST POPULAR',
          isLarge: true,
        ),
        const SizedBox(height: 10),
        // Monthly plan
        _buildPlanTile(
          index: 1,
          price: 'or £2.99/month',
          subtitle: null,
          badge: null,
          isLarge: false,
        ),
        const SizedBox(height: 10),
        // Lifetime plan
        _buildPlanTile(
          index: 2,
          price: '£34.99 one-time',
          subtitle: null,
          badge: null,
          isLarge: false,
        ),
      ],
    );
  }

  Widget _buildPlanTile({
    required int index,
    required String price,
    String? subtitle,
    String? badge,
    required bool isLarge,
  }) {
    final isSelected = _selectedPlan == index;

    return Semantics(
      label: '$price${subtitle != null ? ', $subtitle' : ''}${badge != null ? ', $badge' : ''}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedPlan = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isLarge ? 18 : 14,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.onboardingAmber : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          price,
                          style: isLarge
                              ? GoogleFonts.lora(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                )
                              : GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.onboardingAmber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.onboardingAmber : AppColors.textHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.onboardingAmber,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrialPill() {
    return Semantics(
      label: '7-day free trial, cancel anytime',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.onboardingAmber,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '7-day free trial · Cancel anytime',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 16),
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
          // CTA button
          Semantics(
            label: 'Start my free trial',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onCtaTapped,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingAmber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start my free trial →',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // "Maybe later" — fades in after 1 second
          FadeTransition(
            opacity: _maybeLaterOpacity,
            child: Semantics(
              label: 'Maybe later, skip subscription',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _onSkipTapped,
                  child: Text(
                    'Maybe later',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legal footer
          Text(
            'Terms of Service · Privacy Policy',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
