import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/tank_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_feedback.dart';

class TankPickerSheet extends ConsumerStatefulWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onSelected;
  final VoidCallback onAddTank;

  const TankPickerSheet({
    super.key,
    required this.tanks,
    required this.currentIndex,
    required this.onSelected,
    required this.onAddTank,
  });

  @override
  ConsumerState<TankPickerSheet> createState() => _TankPickerSheetState();
}

class _TankPickerSheetState extends ConsumerState<TankPickerSheet> {
  late List<Tank> _tanks;
  bool _hasReordered = false;

  @override
  void initState() {
    super.initState();
    _tanks = List.from(widget.tanks);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppOverlays.textHint30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg2),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm2),
                Text('Your Tanks', style: AppTypography.headlineSmall),
                const Spacer(),
                if (_hasReordered)
                  TextButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Save'),
                  )
                else
                  TextButton.icon(
                    onPressed: widget.onAddTank,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
              ],
            ),
          ),

          // Tank list (reorderable)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _tanks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  _hasReordered = true;
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final tank = _tanks.removeAt(oldIndex);
                  _tanks.insert(newIndex, tank);
                });
              },
              itemBuilder: (context, index) {
                final tank = _tanks[index];
                final isSelected =
                    tank.id == widget.tanks[widget.currentIndex].id;

                return Container(
                  key: ValueKey(tank.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppOverlays.primary10
                        : AppColors.surfaceVariant,
                    borderRadius: AppRadius.mediumRadius,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => widget.onSelected(_tanks.indexOf(tank)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppOverlays.primary20
                            : Colors.white,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Icon(
                        Icons.water,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      tank.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Icon(Icons.check_circle, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.drag_handle, color: AppColors.textHint),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Hint
          if (_hasReordered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: AppIconSizes.xs, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tap "Save" to keep this order',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Future<void> _saveOrder() async {
    try {
      final actions = ref.read(tankActionsProvider);
      await actions.reorderTanks(_tanks);

      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSuccess(context, 'Tank order saved');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t save the order. Give it another go!',
        );
      }
    }
  }
}
