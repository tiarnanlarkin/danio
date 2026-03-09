import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/rive/rive_fish.dart';

/// Final onboarding screen — shown after PersonalisationScreen.
/// Confirms the user's personalised journey and calls completeOnboarding().
class JourneyRevealScreen extends ConsumerWidget {
  final ExperienceLevel experienceLevel;
  final String tankStatus; // 'yes' | 'planning' | 'exploring'
  final String? userName;

  const JourneyRevealScreen({
    super.key,
    required this.experienceLevel,
    required this.tankStatus,
    this.userName,
  });

  String _headline() {
    if (experienceLevel == ExperienceLevel.beginner) {
      if (tankStatus == 'yes') return 'Your fish are in good hands 🐠';
      if (tankStatus == 'planning') return "Let's get your tank ready 🏠";
      return "Let's start your journey 🌊";
    }
    return 'Welcome back to the hobby 🐟';
  }

  String _subheading() {
    final name = (userName != null && userName!.isNotEmpty) ? userName! : null;
    final greeting = name != null ? 'Hey $name!' : 'Hey there!';
    if (experienceLevel == ExperienceLevel.beginner) {
      return "$greeting Finn is your personal fish guide — always here to help.";
    }
    return "$greeting We know you know your stuff. Finn's here to keep things sharp.";
  }

  static const List<_FeaturePill> _features = [
    _FeaturePill(
      icon: Icons.school_rounded,
      label: 'Step-by-step lessons',
      color: DanioColors.tealWater,
    ),
    _FeaturePill(
      icon: Icons.health_and_safety_rounded,
      label: 'Tank health alerts',
      color: DanioColors.coralAccent,
    ),
    _FeaturePill(
      icon: Icons.set_meal_rounded,
      label: 'Finn — your fish AI',
      color: DanioColors.amberGold,
    ),
  ];

  Future<void> _letsGo(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final service = await OnboardingService.getInstance();
    await service.completeOnboarding();
    ref.invalidate(onboardingCompletedProvider);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen background image
            Semantics(
              image: true,
              label: 'Underwater aquarium background',
              excludeSemantics: true,
              child: Image.asset(
                'assets/images/onboarding/onboarding_journey_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DanioColors.tealWater,
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Dark overlay for readability
            Container(color: AppColors.blackAlpha50),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // Decorative fish at top-centre
                  Semantics(
                    label: 'Finn the fish mascot',
                    excludeSemantics: true,
                    child: const RiveFish(
                      fishType: RiveFishType.emotional,
                      size: 100,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Text(
                      _headline(),
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Subheading
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Text(
                      _subheading(),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.whiteAlpha85,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Feature pills
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: _features.map((f) => _buildFeaturePill(f)).toList(),
                    ),
                  ),

                  const Spacer(),

                  // CTA button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    child: _LetsGoButton(
                      onTap: () => _letsGo(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(_FeaturePill feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.whiteAlpha15,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.whiteAlpha20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: feature.color.withAlpha(51),
                borderRadius: AppRadius.smallRadius,
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: AppIconSizes.md,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              feature.label,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill {
  final IconData icon;
  final String label;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _LetsGoButton extends StatefulWidget {
  final VoidCallback onTap;

  const _LetsGoButton({required this.onTap});

  @override
  State<_LetsGoButton> createState() => _LetsGoButtonState();
}

class _LetsGoButtonState extends State<_LetsGoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) {
          final reduce = MediaQuery.of(context).disableAnimations;
          return Transform.scale(
            scale: reduce ? 1.0 : _scale.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: DanioColors.tealWater,
                borderRadius: AppRadius.mediumRadius,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackAlpha15,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Let's go →",
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
