import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

class SelectionModePanel extends StatelessWidget {
  final List<Tank> tanks;
  final Set<String> selectedIds;
  final Function(String) onToggleSelection;
  final VoidCallback onCancel;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportSelected;

  const SelectionModePanel({
    super.key,
    required this.tanks,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onCancel,
    required this.onDeleteSelected,
    required this.onExportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tank selection list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: AppOverlays.white95,
            borderRadius: AppRadius.mediumRadius,
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black12,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppOverlays.white60,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppOverlays.primary10,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.checklist, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm2),
                    Text(
                      'Select Tanks',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${selectedIds.length} selected',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.close, size: AppIconSizes.sm),
                      tooltip: 'Cancel selection',
                      onPressed: onCancel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Tank list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tanks.length,
                  itemBuilder: (context, index) {
                    final tank = tanks[index];
                    final isSelected = selectedIds.contains(tank.id);

                    return ListTile(
                      onTap: () => onToggleSelection(tank.id),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelection(tank.id),
                      ),
                      title: Text(
                        tank.name,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: Icon(
                        Icons.water,
                        color: isSelected
                            ? AppColors.primary
                            : context.textHint,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm2),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : onDeleteSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumRadius,
                  ),
                ),
                icon: const Icon(Icons.delete_outline, size: AppIconSizes.sm),
                label: const Text('Delete'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : onExportSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumRadius,
                  ),
                ),
                icon: const Icon(Icons.file_download_outlined, size: AppIconSizes.sm),
                label: const Text('Export'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
