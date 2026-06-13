import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../utils/app_constants.dart';

/// First page of tank creation — name and type selection.
class BasicInfoPage extends StatelessWidget {
  final String name;
  final TankType type;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<TankType> onTypeChanged;

  const BasicInfoPage({
    super.key,
    required this.name,
    required this.type,
    required this.onNameChanged,
    required this.onTypeChanged,
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
            child: Text('Name your tank', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Give it a memorable name, like "Living Room Tank" or "Betta Palace".',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: Semantics(
              label: A11yLabels.textField('Tank name', required: true),
              textField: true,
              child: TextFormField(
                initialValue: name,
                maxLength: kTankNameMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  labelText: 'Tank name',
                  hintText: 'e.g., Living Room Tank',
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: onNameChanged,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a tank name'
                    : null,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Semantics(
            header: true,
            child: Text('Tank type', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Danio is focused on freshwater aquariums: tropical, coldwater, planted, shrimp, and nano setups.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          FocusTraversalOrder(
            order: const NumericFocusOrder(2.0),
            child: _TypeSelector(selected: type, onChanged: onTypeChanged),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TankType selected;
  final ValueChanged<TankType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _TypeCard(
      icon: Icons.water_drop,
      title: 'Freshwater',
      subtitle: 'Tropical, coldwater, planted, shrimp, and nano care',
      isSelected: selected == TankType.freshwater,
      onTap: () => onChanged(TankType.freshwater),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.selectableItem(title, isSelected),
      hint: subtitle,
      button: true,
      enabled: true,
      selected: isSelected,
      onTap: onTap,
      excludeSemantics: true,
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
          child: Column(
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? AppColors.primary : context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ExcludeSemantics(
                child: Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? AppColors.primary : context.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(
                child: Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
