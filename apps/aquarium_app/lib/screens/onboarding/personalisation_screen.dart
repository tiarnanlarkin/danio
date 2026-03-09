import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../models/tank.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/rive/rive_fish.dart';
import 'journey_reveal_screen.dart';

/// Unified personalisation screen that replaces ExperienceAssessmentScreen
/// and ProfileCreationScreen. Collects experience level, tank ownership
/// status, and optional name in a single scrollable screen.
class PersonalisationScreen extends ConsumerStatefulWidget {
  const PersonalisationScreen({super.key});

  @override
  ConsumerState<PersonalisationScreen> createState() =>
      _PersonalisationScreenState();
}

class _PersonalisationScreenState extends ConsumerState<PersonalisationScreen> {
  ExperienceLevel? _selectedExperience;
  String? _tankStatus;
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Force-quit recovery: pre-populate from existing profile if present
    final existingProfile = ref.read(userProfileProvider).value;
    if (existingProfile != null) {
      _selectedExperience = existingProfile.experienceLevel;
      if (existingProfile.name != null && existingProfile.name!.isNotEmpty) {
        _nameController.text = existingProfile.name!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedExperience != null && _tankStatus != null && !_isSubmitting;

  UserGoal _deriveGoal() {
    if (_selectedExperience == ExperienceLevel.expert) {
      return UserGoal.masterTheHobby;
    }
    if (_tankStatus == 'yes') return UserGoal.keepFishAlive;
    if (_tankStatus == 'planning') return UserGoal.beautifulDisplay;
    return UserGoal.learnTheScience;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final goal = _deriveGoal();
      final existingProfile = ref.read(userProfileProvider).value;

      if (existingProfile == null) {
        await ref.read(userProfileProvider.notifier).createProfile(
              name: _nameController.text.isEmpty
                  ? null
                  : _nameController.text.trim(),
              experienceLevel: _selectedExperience!,
              primaryTankType: TankType.freshwater,
              goals: [goal],
            );
      } else {
        // Profile exists (force-quit recovery) — update with new values
        await ref.read(userProfileProvider.notifier).updateProfile(
              experienceLevel: _selectedExperience,
              goals: [goal],
              name: _nameController.text.isEmpty
                  ? null
                  : _nameController.text.trim(),
            );
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JourneyRevealScreen(
              experienceLevel: _selectedExperience!,
              tankStatus: _tankStatus!,
              userName: _nameController.text.isEmpty
                  ? null
                  : _nameController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            ),
            // Decorative orb
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.whiteAlpha15,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          // Finn fish at top
                          const RiveFish(
                            fishType: RiveFishType.emotional,
                            size: 80,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Heading
                          Text(
                            'Tell me about you!',
                            style: AppTypography.headlineLarge.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Subheading
                          Text(
                            "Just 3 quick taps — I'll sort the rest.",
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.whiteAlpha80,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Section 1: Experience level
                          _buildSectionLabel("How's your fishkeeping?"),
                          const SizedBox(height: AppSpacing.sm2),
                          _buildExperienceCard(
                            emoji: '🐣',
                            label: 'Brand new to the hobby',
                            value: ExperienceLevel.beginner,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildExperienceCard(
                            emoji: '🐠',
                            label: "I've kept fish before",
                            value: ExperienceLevel.intermediate,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildExperienceCard(
                            emoji: '🐟',
                            label: 'Experienced aquarist',
                            value: ExperienceLevel.expert,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Section 2: Tank status
                          _buildSectionLabel('Do you have a tank right now?'),
                          const SizedBox(height: AppSpacing.sm2),
                          _buildTankStatusCard(
                            emoji: '🏠',
                            label: "Yes, I'm currently keeping fish",
                            value: 'yes',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTankStatusCard(
                            emoji: '🛒',
                            label: 'Setting up soon',
                            value: 'planning',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTankStatusCard(
                            emoji: '💭',
                            label: 'Just exploring for now',
                            value: 'exploring',
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Section 3: Name (optional)
                          _buildSectionLabel('What should Finn call you?'),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Optional',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.whiteAlpha60,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm2),
                          TextField(
                            controller: _nameController,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Tiarnan',
                              hintStyle: AppTypography.bodyLarge.copyWith(
                                color: AppColors.whiteAlpha40,
                              ),
                              filled: true,
                              fillColor: AppColors.whiteAlpha10,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mediumRadius,
                                borderSide: const BorderSide(
                                  color: AppColors.whiteAlpha25,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.mediumRadius,
                                borderSide: const BorderSide(
                                  color: AppColors.whiteAlpha25,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.mediumRadius,
                                borderSide: const BorderSide(
                                  color: AppColors.primaryLight,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Error message
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // CTA Button
                          _buildSubmitButton(),

                          const SizedBox(height: AppSpacing.xxl),
                        ],
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

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.titleMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExperienceCard({
    required String emoji,
    required String label,
    required ExperienceLevel value,
  }) {
    final isSelected = _selectedExperience == value;
    return _buildSelectionCard(
      emoji: emoji,
      label: label,
      isSelected: isSelected,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedExperience = value);
      },
    );
  }

  Widget _buildTankStatusCard({
    required String emoji,
    required String label,
    required String value,
  }) {
    final isSelected = _tankStatus == value;
    return _buildSelectionCard(
      emoji: emoji,
      label: label,
      isSelected: isSelected,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tankStatus = value);
      },
    );
  }

  Widget _buildSelectionCard({
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium2,
        curve: AppCurves.standard,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAlpha25
              : AppColors.whiteAlpha10,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : AppColors.whiteAlpha20,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryLight,
                size: AppIconSizes.md,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: _canSubmit ? 1.0 : 0.5,
        duration: AppDurations.medium2,
        child: _PrimaryButton(
          onTap: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  "Let's Meet Finn! →",
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onTap;
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
    _controller = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
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
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.mediumRadius,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackAlpha15,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.whiteAlpha80,
                    blurRadius: 1,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
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
