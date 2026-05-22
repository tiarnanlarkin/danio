import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Log type selector -- row of chips for picking the log category.
class AddLogTypeSelector extends StatefulWidget {
  final LogType selected;
  final ValueChanged<LogType> onChanged;

  const AddLogTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<AddLogTypeSelector> createState() => _AddLogTypeSelectorState();
}

class _AddLogTypeSelectorState extends State<AddLogTypeSelector> {
  final Map<LogType, GlobalKey> _chipKeys = {
    for (final option in _logTypeOptions) option.type: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollSelectedChipIntoView();
  }

  @override
  void didUpdateWidget(covariant AddLogTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _scrollSelectedChipIntoView();
    }
  }

  void _scrollSelectedChipIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectedContext = _chipKeys[widget.selected]?.currentContext;
      if (selectedContext == null) return;

      Scrollable.ensureVisible(
        selectedContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final option in _logTypeOptions) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: AppSpacing.sm));
      }
      children.add(
        _AddLogTypeChip(
          key: _chipKeys[option.type],
          icon: option.icon,
          label: option.label,
          isSelected: widget.selected == option.type,
          onTap: () => widget.onChanged(option.type),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

const _logTypeOptions = [
  _LogTypeOption(
    type: LogType.waterTest,
    icon: Icons.science,
    label: 'Water Test',
  ),
  _LogTypeOption(
    type: LogType.feeding,
    icon: Icons.restaurant,
    label: 'Feeding',
  ),
  _LogTypeOption(
    type: LogType.waterChange,
    icon: Icons.water_drop,
    label: 'Water Change',
  ),
  _LogTypeOption(
    type: LogType.observation,
    icon: Icons.visibility,
    label: 'Observation',
  ),
  _LogTypeOption(
    type: LogType.medication,
    icon: Icons.medication,
    label: 'Medication',
  ),
];

class _LogTypeOption {
  final LogType type;
  final IconData icon;
  final String label;

  const _LogTypeOption({
    required this.type,
    required this.icon,
    required this.label,
  });
}

class _AddLogTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddLogTypeChip({
    super.key,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
