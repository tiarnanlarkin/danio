import 'package:flutter/material.dart';
import 'package:danio/utils/haptic_feedback.dart';

import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import 'onboarding_layout.dart';

class RegionUnitsChoice {
  final String regionCode;
  final bool useMetric;

  const RegionUnitsChoice({required this.regionCode, required this.useMetric});
}

class RegionUnitsScreen extends StatefulWidget {
  final ValueChanged<RegionUnitsChoice> onContinue;
  final VoidCallback? onSkip;

  const RegionUnitsScreen({super.key, required this.onContinue, this.onSkip});

  @override
  State<RegionUnitsScreen> createState() => _RegionUnitsScreenState();
}

class _RegionUnitsScreenState extends State<RegionUnitsScreen> {
  String? _selectedRegionCode;
  bool _useMetric = true;
  bool _manualUnitChoice = false;

  static const _regions = [
    _RegionOption(
      code: 'gb_ie',
      label: 'UK & Ireland',
      subtitle: 'Litres, cm, C',
      defaultUseMetric: true,
      icon: Icons.flag_outlined,
    ),
    _RegionOption(
      code: 'europe',
      label: 'Europe',
      subtitle: 'Metric care guidance',
      defaultUseMetric: true,
      icon: Icons.public,
    ),
    _RegionOption(
      code: 'us',
      label: 'United States',
      subtitle: 'Gallons, inches, F',
      defaultUseMetric: false,
      icon: Icons.location_on_outlined,
    ),
    _RegionOption(
      code: 'canada',
      label: 'Canada',
      subtitle: 'Metric by default',
      defaultUseMetric: true,
      icon: Icons.map_outlined,
    ),
    _RegionOption(
      code: 'aus_nz',
      label: 'Australia & New Zealand',
      subtitle: 'Metric by default',
      defaultUseMetric: true,
      icon: Icons.terrain_outlined,
    ),
    _RegionOption(
      code: 'other',
      label: 'Somewhere else',
      subtitle: 'Universal guidance',
      defaultUseMetric: true,
      icon: Icons.language,
    ),
  ];

  void _selectRegion(_RegionOption option) {
    AppHaptics.selection(context);
    setState(() {
      _selectedRegionCode = option.code;
      if (!_manualUnitChoice) {
        _useMetric = option.defaultUseMetric;
      }
    });
  }

  void _setUnitPreference(bool useMetric) {
    AppHaptics.selection(context);
    setState(() {
      _useMetric = useMetric;
      _manualUnitChoice = true;
    });
  }

  void _continue() {
    final regionCode = _selectedRegionCode;
    if (regionCode == null) return;
    AppHaptics.medium(context);
    widget.onContinue(
      RegionUnitsChoice(regionCode: regionCode, useMetric: _useMetric),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: OnboardingContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(
                  'Where are you based?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This helps Danio use familiar units and keep guidance clear.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Preferred units',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Metric'),
                    selected: _useMetric,
                    onSelected: (_) => _setUnitPreference(true),
                  ),
                  ChoiceChip(
                    label: const Text('US units'),
                    selected: !_useMetric,
                    onSelected: (_) => _setUnitPreference(false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final region in _regions) ...[
                        _RegionCard(
                          option: region,
                          isSelected: _selectedRegionCode == region.code,
                          onTap: () => _selectRegion(region),
                        ),
                        const SizedBox(height: AppSpacing.sm2),
                      ],
                    ],
                  ),
                ),
              ),
              AppButton(
                label: 'Continue',
                onPressed: _selectedRegionCode == null ? null : _continue,
                enableHaptics: false,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                size: AppButtonSize.large,
                semanticsLabel: 'Continue',
              ),
              if (widget.onSkip != null) ...[
                const SizedBox(height: AppSpacing.sm2),
                AppButton(
                  label: 'Skip for now',
                  onPressed: widget.onSkip,
                  variant: AppButtonVariant.text,
                  isFullWidth: true,
                  semanticsLabel: 'Skip setup for now',
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionOption {
  final String code;
  final String label;
  final String subtitle;
  final bool defaultUseMetric;
  final IconData icon;

  const _RegionOption({
    required this.code,
    required this.label,
    required this.subtitle,
    required this.defaultUseMetric,
    required this.icon,
  });
}

class _RegionCard extends StatelessWidget {
  final _RegionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surface;

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: AppDurations.short,
            curve: AppCurves.standard,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(option.icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
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
      ),
    );
  }
}
