import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/tank_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/logger.dart';
import '../../../utils/app_feedback.dart';
import '../../../widgets/core/app_button.dart';

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
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm2),
            width: 40,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppOverlays.textHint30,
              borderRadius: AppRadius.xxsRadius,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg2),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm2),
                Text('Your Tanks', style: AppTypography.headlineSmall),
                const Spacer(),
                if (_hasReordered)
                  AppButton(
                    label: 'Save',
                    onPressed: _saveOrder,
                    leadingIcon: Icons.check,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                  )
                else
                  AppButton(
                    label: 'Add',
                    onPressed: widget.onAddTank,
                    leadingIcon: Icons.add,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
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
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppOverlays.primary10
                        : context.surfaceVariant,
                    borderRadius: AppRadius.mediumRadius,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => widget.onSelected(_tanks.indexOf(tank)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppOverlays.primary20
                            : context.surfaceVariant,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Icon(
                        Icons.water,
                        color: isSelected
                            ? AppColors.primary
                            : context.textSecondary,
                      ),
                    ),
                    title: Text(
                      tank.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : context.textPrimary,
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
                        Icon(Icons.drag_handle, color: context.textHint),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg2, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppIconSizes.xs,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tap "Save" to keep this order',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
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
        Navigator.maybePop(context);
        AppFeedback.showSuccess(context, 'Tank order saved');
      }
    } catch (e, st) {
      logError('TankPickerSheet: reorder save failed: $e', stackTrace: st, tag: 'TankPickerSheet');
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t save the order. Give it another go!',
        );
      }
    }
  }
}
