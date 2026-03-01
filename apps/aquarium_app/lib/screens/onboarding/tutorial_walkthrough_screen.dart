/// Interactive tutorial walkthrough for first tank setup
/// Final step of onboarding flow before entering the main app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../tab_navigator.dart';

class TutorialWalkthroughScreen extends ConsumerStatefulWidget {
  const TutorialWalkthroughScreen({super.key});

  @override
  ConsumerState<TutorialWalkthroughScreen> createState() =>
      _TutorialWalkthroughScreenState();
}

class _TutorialWalkthroughScreenState
    extends ConsumerState<TutorialWalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Tank creation form state
  final _formKey = GlobalKey<FormState>();
  String _tankName = '';
  TankType _tankType = TankType.freshwater;
  double _volumeLitres = 0;
  String _waterType = 'tropical';

  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      icon: Icons.waves,
      title: 'Welcome to Your Aquarium Journey! 🎉',
      description:
          'You\'ve completed the assessment! Now let\'s set up your first virtual tank to track your real aquarium.',
      emoji: '🐠',
    ),
    _TutorialStep(
      icon: Icons.water_drop,
      title: 'Track Everything in One Place',
      description:
          'Log water parameters, track fish health, set maintenance reminders, and watch your knowledge grow as you learn.',
      emoji: '📊',
    ),
    _TutorialStep(
      icon: Icons.tips_and_updates,
      title: 'Learn as You Go',
      description:
          'Complete lessons to unlock equipment, earn XP, and discover new species. The app gamifies aquarium keeping!',
      emoji: '⭐',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    } else {
      // Move to tank creation form
      setState(() => _currentStep = _steps.length);
    }
  }

  void _previousStep() {
    if (_currentStep > 0 && _currentStep < _steps.length) {
      _pageController.previousPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    } else if (_currentStep == _steps.length) {
      setState(() => _currentStep = _steps.length - 1);
    }
  }

  void _skipTutorial() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TabNavigator()),
      (route) => false,
    );
  }

  Future<void> _createFirstTank() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final actions = ref.read(tankActionsProvider);
      final targets = _waterType == 'tropical'
          ? WaterTargets.freshwaterTropical()
          : WaterTargets.freshwaterColdwater();

      await actions.createTank(
        name: _tankName.trim(),
        type: _tankType,
        volumeLitres: _volumeLitres,
        startDate: DateTime.now(),
        targets: targets,
      );

      if (!mounted) return;

      // Show success and navigate to main app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 ${_tankName.trim()} created! Let\'s start your aquarium journey!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(AppDurations.long2);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TabNavigator()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating tank: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting Started'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(onPressed: _skipTutorial, child: const Text('Skip')),
        ],
      ),
      body: _currentStep < _steps.length
          ? Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / (_steps.length + 1),
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariantDark : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),

                // Tutorial steps
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentStep = index),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) =>
                        _buildTutorialPage(_steps[index]),
                  ),
                ),

                // Navigation
                _buildNavigation(),
              ],
            )
          : _buildTankCreationForm(),
    );
  }

  Widget _buildTutorialPage(_TutorialStep step) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large emoji
          Text(step.emoji, style: Theme.of(context).textTheme.headlineMedium!.copyWith()),
          const SizedBox(height: AppSpacing.xl),

          // Icon
          Container(
            padding: EdgeInsets.all(AppSpacing.lg2),
            decoration: BoxDecoration(
              color: AppOverlays.accent10,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: AppIconSizes.xl, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            step.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            step.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTankCreationForm() {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariantDark : Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(AppColors.accent),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Create Your First Tank 🐟',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This will be your virtual tank to track your real aquarium',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tank name
                  Text(
                    'Tank Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g., Living Room Tank',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a tank name';
                      }
                      return null;
                    },
                    onChanged: (value) => _tankName = value,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tank type
                  Text(
                    'Tank Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TankTypeCard(
                          icon: Icons.water_drop,
                          label: 'Freshwater',
                          isSelected: _tankType == TankType.freshwater,
                          onTap: () =>
                              setState(() => _tankType = TankType.freshwater),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm2),
                      Expanded(
                        child: _TankTypeCard(
                          icon: Icons.waves,
                          label: 'Marine',
                          isSelected: _tankType == TankType.marine,
                          isDisabled: true,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Volume
                  Text(
                    'Tank Size',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g., 120 litres',
                      prefixIcon: Icon(Icons.straighten),
                      suffixText: 'litres',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tank volume';
                      }
                      final volume = double.tryParse(value);
                      if (volume == null || volume <= 0) {
                        return 'Please enter a valid volume';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _volumeLitres = double.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    children: [20, 40, 60, 100, 120, 200].map((volume) {
                      return ActionChip(
                        label: Text('${volume}L'),
                        onPressed: () {
                          setState(() => _volumeLitres = volume.toDouble());
                          // Update text field - find the TextFormField and update it
                          _formKey.currentState?.reset();
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Water type
                  Text(
                    'Water Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _WaterTypeCard(
                    icon: '🌴',
                    label: 'Tropical',
                    subtitle: '24-28°C',
                    isSelected: _waterType == 'tropical',
                    onTap: () => setState(() => _waterType = 'tropical'),
                  ),
                  const SizedBox(height: AppSpacing.sm2),
                  _WaterTypeCard(
                    icon: '❄️',
                    label: 'Coldwater',
                    subtitle: '15-22°C',
                    isSelected: _waterType == 'coldwater',
                    onTap: () => setState(() => _waterType = 'coldwater'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Create button
                  FilledButton(
                    onPressed: _createFirstTank,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Create Tank & Start Journey!',
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm2),
                  OutlinedButton(
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _nextStep,
              child: Text(
                _currentStep == _steps.length - 1 ? 'Create My Tank!' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final String emoji;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class _TankTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TankTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: AppRadius.mediumRadius,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppOverlays.primary10
                : Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.grey[100],
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey[800],
                ),
              ),
              if (isDisabled) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Coming soon',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith( color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterTypeCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _WaterTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumRadius,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppOverlays.accent10
              : Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.grey[100],
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected ? AppColors.accent : Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: Theme.of(context).textTheme.headlineMedium!.copyWith()),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accent : Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith( color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
