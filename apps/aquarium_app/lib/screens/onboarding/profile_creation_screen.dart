/// Simplified profile creation — name + experience level only
/// Tank type, goals, and placement test are deferred to Settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tank.dart';
import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/celebration_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/accessibility_utils.dart';
import '../tab_navigator.dart';

class ProfileCreationScreen extends ConsumerStatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  ConsumerState<ProfileCreationScreen> createState() =>
      _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends ConsumerState<ProfileCreationScreen> {
  final _nameController = TextEditingController();
  ExperienceLevel? _selectedExperience;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _selectedExperience != null;

  Future<void> _createProfile() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your experience level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profileNotifier = ref.read(userProfileProvider.notifier);

      await profileNotifier.createProfile(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        experienceLevel: _selectedExperience!,
        primaryTankType: TankType.freshwater, // Sensible default
        goals: [UserGoal.keepFishAlive], // Sensible default
      );

      if (!mounted) return;

      // Celebrate!
      ref.read(celebrationProvider.notifier).milestone(
            'Welcome Aboard! 🐠',
            subtitle: 'Your aquarium journey begins now!',
          );

      // Go straight to the app
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TabNavigator()),
            (route) => false,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _skipToHome() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(userProfileProvider.notifier).createProfile(
            name: 'Aquarist',
            experienceLevel: ExperienceLevel.beginner,
            primaryTankType: TankType.freshwater,
            goals: [UserGoal.keepFishAlive],
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TabNavigator()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error skipping: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About You'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _skipToHome,
            child: Text(
              'Skip',
              style: TextStyle(
                color: _isSubmitting ? Colors.grey : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              "Let's get to know you 🐠",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Just two quick things and you\'re in!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name field
            Semantics(
              header: true,
              child: Text(
                'What should we call you?',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: A11yLabels.textField('Your name'),
              textField: true,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name (optional)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Experience level
            Semantics(
              header: true,
              child: Text(
                'Your fishkeeping experience',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ...ExperienceLevel.values.map((level) => _buildExperienceCard(level)),

            const SizedBox(height: AppSpacing.xl),

            // Continue button
            Semantics(
              label: A11yLabels.button('Continue to app'),
              button: true,
              enabled: !_isSubmitting && _canSubmit,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _createProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Let's Go!"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceLevel level) {
    final isSelected = _selectedExperience == level;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: A11yLabels.selectableItem(level.displayName, isSelected),
        hint: level.description,
        button: true,
        selected: isSelected,
        onTap: () => setState(() => _selectedExperience = level),
        child: InkWell(
          onTap: () => setState(() => _selectedExperience = level),
          borderRadius: AppRadius.mediumRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppOverlays.accent10 : null,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Text(level.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          level.displayName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ExcludeSemantics(
                        child: Text(
                          level.description,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const ExcludeSemantics(
                    child: Icon(Icons.check_circle, color: AppColors.accent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
