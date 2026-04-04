import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 9 — Push Notification Pre-Prompt
///
/// Shown BEFORE the OS dialog to explain the value of notifications.
/// The caller handles the actual permission request via [onAllow].
class PushPermissionScreen extends StatefulWidget {
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const PushPermissionScreen({
    super.key,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  State<PushPermissionScreen> createState() => _PushPermissionScreenState();
}

class _PushPermissionScreenState extends State<PushPermissionScreen>
    with TickerProviderStateMixin {

  late final AnimationController _fadeController;
  late final CurvedAnimation _fadeCurve;
  late final Animation<double> _fadeAnim;

  late final AnimationController _bellFloatController;
  late final CurvedAnimation _bellFloatCurve;
  late final Animation<double> _bellOffset;

  @override
  void initState() {
    super.initState();

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    // Screen entry fade (200ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.medium2,
    );
    _fadeCurve = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeAnim = _fadeCurve;

    // Bell float animation: translateY -6 to 0, 1.5s ease-in-out loop
    _bellFloatController = AnimationController(
      vsync: this,
      duration: AppDurations.celebration,
    );
    _bellFloatCurve = CurvedAnimation(
      parent: _bellFloatController,
      curve: Curves.easeInOut,
    );
    _bellOffset = Tween<double>(begin: -6.0, end: 0.0).animate(_bellFloatCurve);

    if (!disableAnimations) {
      _fadeController.forward();
      _bellFloatController.repeat(reverse: true);
    } else {
      _fadeController.value = 1.0;
      _bellFloatController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _fadeCurve.dispose();
    _fadeController.dispose();
    _bellFloatCurve.dispose();
    _bellFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration: fish tank with notification bell
                      _buildIllustration(),
                      const SizedBox(height: AppSpacing.xl2),
                      // Headline
                      Text(
                        "We'll tap you when something matters.",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Body
                      Text(
                        "Danio can alert you when your fish's water conditions "
                        "need attention — before small problems become big ones. "
                        "We'll never spam you.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom buttons
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottomPadding + AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary button
                    AppButton(
                      label: 'Yes, keep me informed →',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onAllow();
                      },
                      variant: AppButtonVariant.primary,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                      semanticsLabel: 'Yes, keep me informed',
                    ),
                    const SizedBox(height: AppSpacing.sm4),
                    // Secondary link
                    AppButton(
                      label: 'Not right now',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onSkip();
                      },
                      variant: AppButtonVariant.text,
                      isFullWidth: true,
                      semanticsLabel: 'Not right now, skip notifications',
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

  Widget _buildIllustration() {
    return Semantics(
      label: 'Fish tank with notification bell illustration',
      image: true,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fish tank (water icon) — base layer
            Icon(
              Icons.water_rounded,
              size: 120,
              color: AppColors.onboardingAmber.withAlpha(60),
            ),
            // Notification bell — floating on top
            AnimatedBuilder(
              animation: _bellOffset,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bellOffset.value),
                  child: child,
                );
              },
              child: Icon(
                Icons.notifications_active_rounded,
                size: 64,
                color: AppColors.onboardingAmber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
