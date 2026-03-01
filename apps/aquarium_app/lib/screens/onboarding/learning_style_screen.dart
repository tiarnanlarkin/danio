import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import 'enhanced_tutorial_walkthrough_screen.dart';

/// Asks the user how they prefer to learn after the placement test.
/// Captures preference for future lesson length tuning.
class LearningStyleScreen extends ConsumerStatefulWidget {
  const LearningStyleScreen({super.key});

  @override
  ConsumerState<LearningStyleScreen> createState() =>
      _LearningStyleScreenState();
}

class _LearningStyleScreenState extends ConsumerState<LearningStyleScreen> {
  String? _selected;

  static const _options = [
    _LearningOption(
      key: 'quick',
      emoji: '⚡',
      title: 'Quick lessons (2–3 min)',
      subtitle: 'Bite-sized tips I can fit anywhere',
    ),
    _LearningOption(
      key: 'deep',
      emoji: '🔬',
      title: 'Deep dives (5–10 min)',
      subtitle: 'I want to really understand the science',
    ),
    _LearningOption(
      key: 'adaptive',
      emoji: '🎯',
      title: 'Just show me what I need to know',
      subtitle: 'Keep it practical and relevant',
    ),
  ];

  Future<void> _continue() async {
    if (_selected == null) return;

    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateProfile(learningStylePreference: _selected);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const EnhancedTutorialWalkthroughScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Text(
                'How do you prefer to learn? 🐟',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We'll tailor lessons to your style",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ..._options.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionCard(
                      option: option,
                      isSelected: _selected == option.key,
                      onTap: () => setState(() => _selected = option.key),
                    ),
                  )),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: _selected != null ? _continue : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          const EnhancedTutorialWalkthroughScreen(),
                    ),
                  );
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningOption {
  final String key;
  final String emoji;
  final String title;
  final String subtitle;

  const _LearningOption({
    required this.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _OptionCard extends StatelessWidget {
  final _LearningOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(option.emoji, style: Theme.of(context).textTheme.headlineMedium!.copyWith()),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
