import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../services/celebration_service.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../tab_navigator.dart';

/// Step-by-step wizard for creating first tank
class FirstTankWizardScreen extends ConsumerStatefulWidget {
  final ExperienceLevel experienceLevel;

  const FirstTankWizardScreen({super.key, required this.experienceLevel});

  @override
  ConsumerState<FirstTankWizardScreen> createState() =>
      _FirstTankWizardScreenState();
}

class _FirstTankWizardScreenState extends ConsumerState<FirstTankWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Tank data
  String _tankName = '';
  double _volumeLitres = 0;
  TankType _tankType = TankType.freshwater;

  final _nameController = TextEditingController();
  final _volumeLitresController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _volumeLitresController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    } else {
      _createTank();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _tankName.isNotEmpty;
      case 1:
        return _volumeLitres > 0;
      case 2:
        return true; // Tank type always has a value
      case 3:
        return true; // Sample data is optional
      default:
        return false;
    }
  }

  Future<void> _createTank() async {
    // Use tankActionsProvider to create the tank
    await ref
        .read(tankActionsProvider)
        .createTank(
          name: _tankName,
          type: _tankType,
          volumeLitres: _volumeLitres,
        );

    // Mark onboarding complete before navigating
    final onboardingService = await OnboardingService.getInstance();
    await onboardingService.completeOnboarding();

    if (mounted) {
      // 🎉 Celebrate first tank creation!
      // Celebration overlay lives in MaterialApp.builder — survives navigation.
      ref.read(celebrationProvider.notifier).milestone(
        'Tank Created! 🐠',
        subtitle: 'Welcome to your aquarium journey!',
      );
      
      // Navigate immediately — celebration overlay is above the nav stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TabNavigator()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildNameStep(),
                  _buildSizeStep(),
                  _buildTypeStep(),
                  _buildSampleDataStep(),
                ],
              ),
            ),

            // Navigation buttons — SafeArea keeps them above gesture nav zone.
            SafeArea(
              top: false,
              child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
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
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _nextStep : null,
                      child: Text(_currentStep == 3 ? 'Create Tank!' : 'Next'),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.edit_rounded, size: AppIconSizes.xxl, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Name Your Tank',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'Give it a memorable name',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Tank Name',
              hintText: 'e.g., Living Room Tank, Main Display',
              prefixIcon: const Icon(Icons.water_drop_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mediumRadius,
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() => _tankName = value),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Examples: "Living Room Tank", "Bedroom Aquarium", "My First Tank"',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeStep() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.straighten_rounded, size: AppIconSizes.xxl, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tank Size',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'How many gallons/liters is your tank?',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          TextField(
            controller: _volumeLitresController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Volume (gallons or liters)',
              hintText: 'e.g., 20',
              prefixIcon: const Icon(Icons.water_outlined),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mediumRadius,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _volumeLitres = double.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Common sizes: 10, 20, 29, 40, 55, 75 gallons',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.waves_rounded, size: AppIconSizes.xxl, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Water Type',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'What type of tank is this?',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          ...TankType.values.map((type) {
            final isSelected = _tankType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _tankType = type),
                  borderRadius: AppRadius.mediumRadius,
                  child: AnimatedContainer(
                    duration: AppDurations.medium2,
                    padding: EdgeInsets.all(AppSpacing.lg2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: AppRadius.mediumRadius,
                      color: isSelected
                          ? AppOverlays.primary10
                          : AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTankTypeIcon(type),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTankTypeName(type),
                                style: AppTypography.titleMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _getTankTypeDescription(type),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSampleDataStep() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ready to Create!',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(
            'Your tank is ready to be created',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl2),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg2),
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppOverlays.primary30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Name', _tankName),
                const SizedBox(height: AppSpacing.sm2),
                _buildSummaryRow(
                  'Size',
                  '${_volumeLitres.toStringAsFixed(1)} liters (${(_volumeLitres * 0.264172).toStringAsFixed(1)} gallons)',
                ),
                const SizedBox(height: AppSpacing.sm2),
                _buildSummaryRow('Type', _getTankTypeName(_tankType)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppOverlays.accent10,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    'After creating, you can add fish, equipment, and log water parameters!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getTankTypeIcon(TankType type) {
    switch (type) {
      case TankType.freshwater:
        return Icons.water_drop_outlined;
      case TankType.marine:
        return Icons.sailing_rounded;
    }
  }

  String _getTankTypeName(TankType type) {
    switch (type) {
      case TankType.freshwater:
        return 'Freshwater';
      case TankType.marine:
        return 'Saltwater / Reef';
    }
  }

  String _getTankTypeDescription(TankType type) {
    switch (type) {
      case TankType.freshwater:
        return 'Most common - tropical fish, tetras, bettas';
      case TankType.marine:
        return 'Marine fish and corals';
    }
  }
}
