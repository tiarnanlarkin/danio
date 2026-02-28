import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../models/tank.dart';
import '../providers/user_profile_provider.dart';
import 'onboarding/profile_creation_screen.dart';
import 'tab_navigator.dart';

/// Simplified single-page onboarding — welcome + "Get Started"
/// Profile details collected on next screen (name + experience only)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: AppCurves.standardDecelerate),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: AppCurves.standardDecelerate));
    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _getStarted() async {
    HapticFeedback.mediumImpact();
    final service = await OnboardingService.getInstance();
    await service.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileCreationScreen()),
      );
    }
  }

  /// Quick Start — skip everything with sensible defaults
  Future<void> _quickStart() async {
    try {
      HapticFeedback.mediumImpact();
      await ref.read(userProfileProvider.notifier).createProfile(
            name: 'Aquarist',
            experienceLevel: ExperienceLevel.beginner,
            primaryTankType: TankType.freshwater,
            goals: [UserGoal.keepFishAlive],
          );
      final service = await OnboardingService.getInstance();
      await service.completeOnboarding();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TabNavigator()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quick start failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3D7068), Color(0xFF5B9A8B), Color(0xFF3D7068)],
                ),
              ),
            ),
            // Decorative orbs
            Positioned(
              top: -100, left: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.whiteAlpha15, Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: 100, right: -80,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.whiteAlpha10, Colors.transparent]),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Quick Start button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _quickStart,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.whiteAlpha15,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.flash_on, size: AppIconSizes.sm),
                          label: const Text('Quick Start'),
                        ),
                      ],
                    ),
                  ),
                  // Hero content
                  Expanded(
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Glass icon
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 160, height: 160,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteAlpha15,
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(color: AppColors.whiteAlpha30, width: 1.5),
                                    ),
                                    child: const Icon(Icons.water_drop_rounded, size: 80, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Aquarium',
                                style: AppTypography.headlineLarge.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5, fontSize: 36,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Learn fishkeeping the fun way',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.whiteAlpha85, height: 1.5, fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Feature chips
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildChip(Icons.school, 'Learn'),
                                  const SizedBox(width: 12),
                                  _buildChip(Icons.track_changes, 'Track'),
                                  const SizedBox(width: 12),
                                  _buildChip(Icons.emoji_events, 'Achieve'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Get Started button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: _PrimaryButton(
                      onTap: _getStarted,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(color: Color(0xFF3D7068), fontWeight: FontWeight.w700, fontSize: 16),
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

  Widget _buildChip(IconData icon, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.whiteAlpha15,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.whiteAlpha25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _PrimaryButton({required this.onTap, required this.child});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppDurations.short, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: AppColors.blackAlpha15, blurRadius: 20, offset: const Offset(0, 8)),
                  BoxShadow(color: AppColors.whiteAlpha80, blurRadius: 1, offset: const Offset(0, -1)),
                ],
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Color(0xFF3D7068)),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
