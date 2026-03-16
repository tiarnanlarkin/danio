import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/notification_service.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';


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
      return "$greeting Your personalised fish guide is ready — let's dive in.";
    }
    return "$greeting We know you know your stuff. Let's keep things sharp.";
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
      label: 'AI fish assistant',
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
                'assets/images/onboarding/onboarding_journey_bg.webp',
                fit: BoxFit.cover,
                cacheWidth: 800,
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

                  const SizedBox(height: AppSpacing.xl),

                  // Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        _headline(),
                        style: AppTypography.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

                  const SizedBox(height: AppSpacing.lg),

                  // Notification permission prompt
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _NotificationPermissionCard(),
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
                    child: Semantics(
                      button: true,
                      label: "Let's go",
                      hint: 'Complete onboarding and start using Danio',
                      child: _LetsGoButton(
                        onTap: () => _letsGo(context, ref),
                      ),
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
    return Semantics(
      label: feature.label,
      child: Padding(
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
    ),
    );
  }
}

/// Inline notification permission prompt shown during onboarding.
/// Respects a SharedPreferences flag so the user is never asked twice.
class _NotificationPermissionCard extends StatefulWidget {
  const _NotificationPermissionCard();

  @override
  State<_NotificationPermissionCard> createState() =>
      _NotificationPermissionCardState();
}

class _NotificationPermissionCardState
    extends State<_NotificationPermissionCard> {
  static const _prefKey = 'notification_permission_requested';
  bool _alreadyRequested = true; // hide by default until check completes
  bool _responded = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyRequested();
  }

  Future<void> _checkAlreadyRequested() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _alreadyRequested = prefs.getBool(_prefKey) ?? false;
    });
  }

  Future<void> _handleAllow() async {
    setState(() => _responded = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    try {
      await NotificationService().requestPermissions();
    } catch (_) {
      // Best-effort — never block onboarding
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _responded = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_alreadyRequested || _responded) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha15,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.whiteAlpha20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get reminded about water changes and streak goals 💧',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _handleSkip,
                  child: Text(
                    'Maybe Later',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.whiteAlpha85,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DanioColors.tealWater,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  child: const Text('Allow Notifications'),
                ),
              ),
            ],
          ),
        ],
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
