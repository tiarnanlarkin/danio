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
        name: 'Aquarist',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      if (!mounted) return;

      // Pop back to the caller. Two cases:
      // (a) Pushed from LearnScreen via Navigator.push → pop() returns to
      //     LearnScreen which rebuilds via userProfileProvider.
      // (b) Shown as root widget by _AppRouterState (_needsProfile=true) →
      //     _AppRouterState now listens to userProfileProvider and will
      //     auto-transition to TabNavigator; pop() would be a no-op here but
      //     we check canPop() to avoid any "cannot pop only route" assertion.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // else: _AppRouterState listener handles the transition automatically.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
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
            'Almost there! Just pick your experience level, tank type, and at least one goal to continue.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profileNotifier = ref.read(userProfileProvider.notifier);

      // Capture form values before any async work
      final name = _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim();
      final experience = _selectedExperience!;
      final tankType = _selectedTankType!;
      final goals = _selectedGoals.toList();

      if (!mounted) return;

      // Navigate BEFORE the provider update so _AppRouter's reactive rebuild
      // (ProfileCreationScreen → TabNavigator) doesn't dispose this widget
      // mid-execution and crash the pending Navigator.push call.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EnhancedPlacementTestScreen(),
        ),
      );

      // Create profile after navigation is queued — provider update now
      // happens with PlacementTestScreen on top, so _AppRouter's rebuild
      // simply changes the background body (ProfileCreationScreen →
      // TabNavigator) without affecting the foreground route.
      await profileNotifier.createProfile(
        name: name,
        experienceLevel: experience,
        primaryTankType: tankType,
        goals: goals,
      );
    } catch (e) {
      if (!mounted) return;

      // If profile creation failed, pop back so the user can retry.
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Couldn\'t set up your profile. Please try again.'),
          backgroundColor: AppColors.error,
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
                color: _isSubmitting ? AppColors.textHint : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Text(
                  'Welcome to Danio! 🐠',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Let\'s personalize your learning experience',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Name field (optional)
                _buildNameField(),
                const SizedBox(height: AppSpacing.lg),

                // Experience level (required)
                _buildExperienceLevelSection(),
                const SizedBox(height: AppSpacing.lg),

                // Tank type (required)
                _buildTankTypeSection(),
                const SizedBox(height: AppSpacing.lg),

                // Goals (at least one required)
                _buildGoalsSection(),
                const SizedBox(height: AppSpacing.xl),

                // Continue button
                FocusTraversalOrder(
                  order: const NumericFocusOrder(5.0),
                  child: Semantics(
                    label: A11yLabels.button(
                      'Continue to next step',
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
                          : const Text('Continue'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Next: A quick quiz to personalise your learning path (2–3 min)',
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
          const SizedBox(height: AppSpacing.sm2),
          Semantics(
            label: A11yLabels.textField('Your name'),
            textField: true,
            child: TextFormField(
              controller: _nameController,
              maxLength: 50,
              decoration: const InputDecoration(
                hintText: 'e.g., Alex',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v != null && v.trim().length > 50) {
                  return 'Name must be 50 characters or fewer';
                }
                return null;
              },
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
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '*',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
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
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppOverlays.accent10 : null,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: isSelected ? AppColors.accent : Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.border,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Text(
                    level.emoji,
                    style: Theme.of(context).textTheme.headlineMedium!,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          level.displayName,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      ExcludeSemantics(
                        child: Text(
                          level.description,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '*',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTankTypeCard(TankType.freshwater)),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(child: _buildTankTypeCard(TankType.marine)),
              ],
            ),
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
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm2),
          decoration: BoxDecoration(
            color: isSelected ? AppOverlays.primary10 : null,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.border,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(type.emoji, style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 40)),
              ),
              SizedBox(height: AppSpacing.xs2),
              ExcludeSemantics(
                child: Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 3),
              Flexible(
                child: ExcludeSemantics(
                  child: Text(
                    type.description,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: AppSpacing.xs2),
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
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '*',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
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
            const SizedBox(width: AppSpacing.xs2),
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
        selectedColor: AppColors.accentAlpha20,
        checkmarkColor: AppColors.accent,
        side: BorderSide(
          color: isSelected ? AppColors.accent : Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.border,
        ),
      ),
    );
  }
}
