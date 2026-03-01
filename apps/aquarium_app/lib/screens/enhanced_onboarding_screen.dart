import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tank.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../services/celebration_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/mascot/mascot_widgets.dart';
import 'home/home_screen.dart';

/// Enhanced onboarding that personalizes the app experience
/// Asks about experience level, tank type, and goals
class EnhancedOnboardingScreen extends ConsumerStatefulWidget {
  const EnhancedOnboardingScreen({super.key});

  @override
  ConsumerState<EnhancedOnboardingScreen> createState() =>
      _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState
    extends ConsumerState<EnhancedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selections
  ExperienceLevel? _experienceLevel;
  TankType? _tankType;
  final Set<UserGoal> _goals = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _complete() async {
    if (_experienceLevel == null || _tankType == null || _goals.isEmpty) {
      return;
    }

    try {
      await ref
          .read(userProfileProvider.notifier)
          .createProfile(
            experienceLevel: _experienceLevel!,
            primaryTankType: _tankType!,
            goals: _goals.toList(),
          );

      if (mounted) {
        // 🎉 Celebrate onboarding completion!
        ref.read(celebrationProvider.notifier).milestone(
          'Welcome Aboard! 🐠',
          subtitle: 'Your aquarium journey begins now!',
        );
        
        // Navigate after a brief moment for the celebration to show
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Oops! Couldn\'t set up your profile. Let\'s try that again.',
          onRetry: _complete,
        );
      }
    }
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true; // Welcome page
      case 1:
        return _experienceLevel != null;
      case 2:
        return _tankType != null;
      case 3:
        return _goals.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _skipOnboarding() async {
    try {
      // Create default profile
      await ref
          .read(userProfileProvider.notifier)
          .createProfile(
            experienceLevel: ExperienceLevel.beginner,
            primaryTankType: TankType.freshwater,
            goals: [UserGoal.keepFishAlive],
          );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Something went sideways. Tap to try again!',
          onRetry: _skipOnboarding,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  // Progress bars
                  Expanded(
                    child: Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 3 ? AppSpacing.sm : 0),
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Skip button (only on welcome page)
                  if (_currentPage == 0) ...[
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(),
                  _ExperiencePage(
                    selected: _experienceLevel,
                    onSelect: (level) =>
                        setState(() => _experienceLevel = level),
                  ),
                  _TankTypePage(
                    selected: _tankType,
                    onSelect: (type) => setState(() => _tankType = type),
                  ),
                  _GoalsPage(
                    selected: _goals,
                    onToggle: (goal) {
                      setState(() {
                        if (_goals.contains(goal)) {
                          _goals.remove(goal);
                        } else {
                          _goals.add(goal);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed
                          ? (_currentPage == 3 ? _complete : _nextPage)
                          : null,
                      child: Text(
                        _currentPage == 0
                            ? "Let's Go!"
                            : _currentPage == 3
                            ? 'Start Learning'
                            : 'Continue',
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
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Finn the mascot
          const MascotAvatar(
            mood: MascotMood.waving,
            size: MascotSize.large,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Mascot greeting bubble
          MascotBubble.fromContext(
            context: MascotContext.welcome,
            size: MascotSize.small,
            animateEntrance: true,
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to Danio! 🐠',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Your aquarium journey starts now!\n\nJust a few quick questions and we'll build your personalised learning path.",
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeatureChip(icon: Icons.school, label: 'Learn'),
              const SizedBox(width: 12),
              _FeatureChip(icon: Icons.track_changes, label: 'Track'),
              const SizedBox(width: 12),
              _FeatureChip(icon: Icons.emoji_events, label: 'Achieve'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppOverlays.primary10,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ExperiencePage extends StatelessWidget {
  final ExperienceLevel? selected;
  final ValueChanged<ExperienceLevel> onSelect;

  const _ExperiencePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'How experienced are you with fishkeeping?',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "No wrong answers here -- this helps us tailor your journey!",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.builder(
              itemCount: ExperienceLevel.values.length,
              itemBuilder: (context, index) {
                final level = ExperienceLevel.values[index];
                final isSelected = selected == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SelectionCard(
                    emoji: level.emoji,
                    title: level.displayName,
                    description: level.description,
                    isSelected: isSelected,
                    onTap: () => onSelect(level),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TankTypePage extends StatelessWidget {
  final TankType? selected;
  final ValueChanged<TankType> onSelect;

  const _TankTypePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What type of tank do you have (or want)?',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll show relevant guides and tips",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.builder(
              itemCount: TankType.values.length,
              itemBuilder: (context, index) {
                final type = TankType.values[index];
                final isSelected = selected == type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
                  child: _SelectionCard(
                    emoji: type.emoji,
                    title: type.displayName,
                    description: type.description,
                    isSelected: isSelected,
                    onTap: () => onSelect(type),
                    compact: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsPage extends StatelessWidget {
  final Set<UserGoal> selected;
  final ValueChanged<UserGoal> onToggle;

  const _GoalsPage({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('What are your goals?', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Pick as many as you like!",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.builder(
              itemCount: UserGoal.values.length,
              itemBuilder: (context, index) {
                final goal = UserGoal.values[index];
                final isSelected = selected.contains(goal);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
                  child: _SelectionCard(
                    emoji: goal.emoji,
                    title: goal.displayName,
                    isSelected: isSelected,
                    onTap: () => onToggle(goal),
                    isMultiSelect: true,
                    compact: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMultiSelect;
  final bool compact;

  const _SelectionCard({
    required this.emoji,
    required this.title,
    this.description,
    required this.isSelected,
    required this.onTap,
    this.isMultiSelect = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppOverlays.primary10
              : AppColors.surface,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: compact ? 28 : 36)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: compact
                        ? AppTypography.labelLarge
                        : AppTypography.headlineSmall,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isMultiSelect)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
