import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../widgets/core/app_button.dart';

/// Third page of tank creation — water type and start date.
class WaterTypePage extends StatelessWidget {
  final String waterType;
  final DateTime startDate;
  final ValueChanged<String> onWaterTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;

  const WaterTypePage({
    super.key,
    required this.waterType,
    required this.startDate,
    required this.onWaterTypeChanged,
    required this.onStartDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Water type', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This sets default temperature and parameter targets.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: _WaterTypeSelector(
              selected: waterType,
              onChanged: onWaterTypeChanged,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Semantics(
            header: true,
            child: Text(
              'When did you set up this tank?',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Helps track cycling progress and maintenance history.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          FocusTraversalOrder(
            order: const NumericFocusOrder(2.0),
            child: Semantics(
              label: A11yLabels.button(
                'Select start date',
                'Currently ${startDate.day}/${startDate.month}/${startDate.year}',
              ),
              button: true,
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    onStartDateChanged(picked);
                  }
                },
                borderRadius: AppRadius.mediumRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm4,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.calendar_today,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm2),
                      ExcludeSemantics(
                        child: Text(
                          '${startDate.day}/${startDate.month}/${startDate.year}',
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      const Spacer(),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.edit,
                          color: context.textHint,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          FocusTraversalOrder(
            order: const NumericFocusOrder(3.0),
            child: Semantics(
              label: A11yLabels.button('Set start date to today'),
              button: true,
              child: AppButton(
                label: 'Set to today',
                onPressed: () => onStartDateChanged(DateTime.now()),
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _WaterTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WaterTypeOption(
          icon: '🌴',
          title: 'Tropical',
          subtitle: '24-28°C • Most community fish',
          isSelected: selected == 'tropical',
          onTap: () => onChanged('tropical'),
        ),
        const SizedBox(height: AppSpacing.sm2),
        _WaterTypeOption(
          icon: '❄️',
          title: 'Coldwater',
          subtitle: '15-22°C • Goldfish, minnows',
          isSelected: selected == 'coldwater',
          onTap: () => onChanged('coldwater'),
        ),
      ],
    );
  }
}

class _WaterTypeOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _WaterTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.selectableItem(title, isSelected),
      hint: subtitle,
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppOverlays.primary10 : context.surfaceVariant,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  icon,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    ExcludeSemantics(
                      child: Text(subtitle, style: AppTypography.bodySmall),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const ExcludeSemantics(
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
