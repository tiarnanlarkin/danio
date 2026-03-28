import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Log type selector — row of chips for picking the log category.
class AddLogTypeSelector extends StatelessWidget {
  final LogType selected;
  final ValueChanged<LogType> onChanged;

  const AddLogTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _AddLogTypeChip(
            icon: Icons.science,
            label: 'Water Test',
            isSelected: selected == LogType.waterTest,
            onTap: () => onChanged(LogType.waterTest),
          ),
          const SizedBox(width: AppSpacing.sm),
          _AddLogTypeChip(
            icon: Icons.water_drop,
            label: 'Water Change',
            isSelected: selected == LogType.waterChange,
            onTap: () => onChanged(LogType.waterChange),
          ),
          const SizedBox(width: AppSpacing.sm),
          _AddLogTypeChip(
            icon: Icons.visibility,
            label: 'Observation',
            isSelected: selected == LogType.observation,
            onTap: () => onChanged(LogType.observation),
          ),
          const SizedBox(width: AppSpacing.sm),
          _AddLogTypeChip(
            icon: Icons.medication,
            label: 'Medication',
            isSelected: selected == LogType.medication,
            onTap: () => onChanged(LogType.medication),
          ),
        ],
      ),
    );
  }
}

class _AddLogTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddLogTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.largeRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : context.surfaceVariant,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.onPrimary : context.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.onPrimary : context.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
