import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/user_profile.dart';
import '../models/tank.dart';
import '../providers/onboarding_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/onboarding_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'onboarding/welcome_screen.dart';
import 'onboarding/experience_level_screen.dart';
import 'onboarding/tank_status_screen.dart';
import 'onboarding/micro_lesson_screen.dart';
import 'onboarding/xp_celebration_screen.dart';
import 'onboarding/fish_select_screen.dart';
import 'onboarding/aha_moment_screen.dart';
import 'onboarding/paywall_stub_screen.dart';
import 'onboarding/push_permission_screen.dart';
import 'onboarding/warm_entry_screen.dart';

/// Orchestrates the 10-screen onboarding flow.
///
/// Uses a [PageView] with [NeverScrollableScrollPhysics] so navigation is
/// purely programmatic (no swiping). State collected across screens is held
/// in this widget and passed down to each child.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  // State collected across screens
  ExperienceLevel? _experienceLevel;
  String? _tankStatus; // 'planning' | 'cycling' | 'active'
  SpeciesInfo? _selectedFish;
  String? _userName;

  static const _totalPages = 10;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final nextIndex = (_pageController.page?.round() ?? 0) + 1;
    if (nextIndex < _totalPages) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Notification permission handler ──────────────────────────────────
  Future<void> _handleNotificationAllow() async {
    try {
      final notificationService = NotificationService();
      await notificationService.requestPermissions();
    } catch (_) {}
    _nextPage();
  }

  // ── Derive a goal from collected state ───────────────────────────────
  UserGoal _deriveGoal() {
    if (_tankStatus == 'planning') return UserGoal.learnTheScience;
    if (_experienceLevel == ExperienceLevel.expert) {
      return UserGoal.masterTheHobby;
    }
    return UserGoal.keepFishAlive;
  }

  // ── Complete onboarding ──────────────────────────────────────────────
  Future<void> _completeOnboarding() async {
    try {
      // 1. Create or update profile with all collected data
      final existingProfile = ref.read(userProfileProvider).value;
      if (existingProfile == null) {
        await ref.read(userProfileProvider.notifier).createProfile(
          experienceLevel: _experienceLevel!,
          primaryTankType: TankType.freshwater,
          goals: [_deriveGoal()],
        );
        // Persist the new onboarding fields
        await ref.read(userProfileProvider.notifier).updateProfile(
          tankStatus: _tankStatus,
          firstFishSpeciesId: _selectedFish?.commonName,
        );
      } else {
        await ref.read(userProfileProvider.notifier).updateProfile(
          experienceLevel: _experienceLevel,
          goals: [_deriveGoal()],
          tankStatus: _tankStatus,
          firstFishSpeciesId: _selectedFish?.commonName,
        );
      }

      // 2. Add 10 XP from micro-lesson
      try {
        await ref.read(userProfileProvider.notifier).addXp(10);
      } catch (_) {}

      // 3. Schedule onboarding notifications
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleOnboardingSequence();
      } catch (_) {}

      // 4. Complete onboarding via service + invalidate provider
      final service = await OnboardingService.getInstance();
      await service.completeOnboarding();
      ref.invalidate(onboardingCompletedProvider);

      // 5. Pop to root — AppRouter sees onboardingCompleted=true → TabNavigator
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Give it another go!"),
          ),
        );
      }
    }
  }

  /// Quick Start — create a default beginner profile and complete onboarding
  /// without going through the personalisation flow.
  Future<void> _quickStart() async {
    try {
      HapticFeedback.mediumImpact();
      await ref.read(userProfileProvider.notifier).createProfile(
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
      final service = await OnboardingService.getInstance();
      await service.completeOnboarding();
      ref.invalidate(onboardingCompletedProvider);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't get started. Give it another go!"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Page 0: Welcome
            WelcomeScreen(
              onNext: _nextPage,
              onLogin: null,
            ),

            // Page 1: Experience Level
            ExperienceLevelScreen(
              onSelected: (level) {
                setState(() => _experienceLevel = level);
                _nextPage();
              },
            ),

            // Page 2: Tank Status
            TankStatusScreen(
              onSelected: (status) {
                setState(() => _tankStatus = status);
                _nextPage();
              },
            ),

            // Page 3: Micro Lesson
            // experienceLevel may be null if user somehow reaches here without
            // selecting — default to beginner.
            MicroLessonScreen(
              experienceLevel: _experienceLevel ?? ExperienceLevel.beginner,
              onComplete: _nextPage,
            ),

            // Page 4: XP Celebration
            XpCelebrationScreen(onNext: _nextPage),

            // Page 5: Fish Select
            FishSelectScreen(
              tankStatus: _tankStatus ?? 'planning',
              onFishSelected: (fish) {
                setState(() => _selectedFish = fish);
                _nextPage();
              },
            ),

            // Page 6: Aha Moment
            // Uses a Builder to defer construction until state is available.
            Builder(builder: (context) {
              if (_selectedFish == null ||
                  _experienceLevel == null ||
                  _tankStatus == null) {
                return const SizedBox.shrink();
              }
              return AhaMomentScreen(
                selectedFish: _selectedFish!,
                experienceLevel: _experienceLevel!,
                tankStatus: _tankStatus!,
                onComplete: _nextPage,
              );
            }),

            // Page 7: Paywall Stub
            Builder(builder: (context) {
              if (_selectedFish == null) {
                return const SizedBox.shrink();
              }
              return PaywallStubScreen(
                selectedFish: _selectedFish!,
                onComplete: _nextPage,
                onSkip: _nextPage,
              );
            }),

            // Page 8: Push Permission
            PushPermissionScreen(
              onAllow: _handleNotificationAllow,
              onSkip: _nextPage,
            ),

            // Page 9: Warm Entry
            Builder(builder: (context) {
              if (_selectedFish == null ||
                  _experienceLevel == null ||
                  _tankStatus == null) {
                return const SizedBox.shrink();
              }
              return WarmEntryScreen(
                selectedFish: _selectedFish!,
                experienceLevel: _experienceLevel!,
                tankStatus: _tankStatus!,
                userName: _userName,
                onReady: _completeOnboarding,
              );
            }),
          ],
        ),
      ),
    );
  }
}
