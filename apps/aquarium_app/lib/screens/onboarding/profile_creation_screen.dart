/// Profile creation screen for new users
/// Part of the onboarding flow - collects user preferences and experience
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tank.dart';
import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import 'enhanced_placement_test_screen.dart';
import '../../utils/accessibility_utils.dart';
import '../home_screen.dart';

class ProfileCreationScreen extends ConsumerStatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  ConsumerState<ProfileCreationScreen> createState() =>
      _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends ConsumerState<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  ExperienceLevel? _selectedExperience;
  TankType? _selectedTankType;
  final Set<UserGoal> _selectedGoals = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    // Experience level and tank type are required
    // At least one goal should be selected
    return _selectedExperience != null &&
        _selectedTankType != null &&
        _selectedGoals.isNotEmpty;
  }

  Future<void> _skipToHome() async {
    setState(() => _isSubmitting = true);

    try {
      final profileNotifier = ref.read(userProfileProvider.notifier);

      // Create default profile for dev/testing
      await profileNotifier.createProfile(
        name: 'Dev User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      if (!mounted) return;

      // Skip directly to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error skipping: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _createProfile() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your experience level, tank type, and at least one goal',
          ),
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
        primaryTankType: _selectedTankType!,
        goals: _selectedGoals.toList(),
      );

      if (!mounted) return;

      // Navigate to placement test
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EnhancedPlacementTestScreen(),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
        automaticallyImplyLeading:
            false, // No back button - must complete onboarding
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
        padding: const EdgeInsets.all(24),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Text(
                  'Welcome to Aquarium! 🐠',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s personalize your learning experience',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name field (optional)
                _buildNameField(),
                const SizedBox(height: 24),

                // Experience level (required)
                _buildExperienceLevelSection(),
                const SizedBox(height: 24),

                // Tank type (required)
                _buildTankTypeSection(),
                const SizedBox(height: 24),

                // Goals (at least one required)
                _buildGoalsSection(),
                const SizedBox(height: 32),

                // Continue button
                FocusTraversalOrder(
                  order: const NumericFocusOrder(5.0),
                  child: Semantics(
                    label: A11yLabels.button(
                      'Continue to knowledge assessment',
                    ),
                    button: true,
                    enabled: !_isSubmitting && _canSubmit,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _createProfile,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue to Assessment'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Next: Quick knowledge check (2-3 minutes)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'What should we call you? (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: A11yLabels.textField('Your name'),
            textField: true,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceLevelSection() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Text(
                  'Experience Level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...ExperienceLevel.values.map((level) => _buildExperienceCard(level)),
        ],
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Text(
                    level.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          level.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ExcludeSemantics(
                        child: Text(
                          level.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
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

  Widget _buildTankTypeSection() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Text(
                  'Primary Tank Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTankTypeCard(TankType.freshwater)),
              const SizedBox(width: 12),
              Expanded(child: _buildTankTypeCard(TankType.marine)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTankTypeCard(TankType type) {
    final isSelected = _selectedTankType == type;

    return Semantics(
      label: A11yLabels.selectableItem(type.displayName, isSelected),
      hint: type.description,
      button: true,
      selected: isSelected,
      onTap: () => setState(() => _selectedTankType = type),
      child: InkWell(
        onTap: () => setState(() => _selectedTankType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(type.emoji, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Text(
                  type.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 3),
              ExcludeSemantics(
                child: Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Text(
                  'Your Goals (Select all that apply)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserGoal.values
                .map((goal) => _buildGoalChip(goal))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChip(UserGoal goal) {
    final isSelected = _selectedGoals.contains(goal);

    return Semantics(
      label: A11yLabels.selectableItem(goal.displayName, isSelected),
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Text(goal.emoji)),
            const SizedBox(width: 6),
            ExcludeSemantics(child: Text(goal.displayName)),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedGoals.add(goal);
            } else {
              _selectedGoals.remove(goal);
            }
          });
        },
        selectedColor: AppColors.accent.withOpacity(0.2),
        checkmarkColor: AppColors.accent,
        side: BorderSide(
          color: isSelected ? AppColors.accent : Colors.grey[300]!,
        ),
      ),
    );
  }
}
