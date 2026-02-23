import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import 'tank_picker_sheet.dart';

class TankSwitcher extends StatelessWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onChanged;
  final VoidCallback onAddTank;
  final VoidCallback? onLongPress;

  const TankSwitcher({
    super.key,
    required this.tanks,
    required this.currentIndex,
    required this.onChanged,
    required this.onAddTank,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleTanks = tanks.length > 1;

    // Clean card-only design - tap to open picker
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppOverlays.white95,
            AppOverlays.white88,
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black12,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppOverlays.white60, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMultipleTanks ? () => _showTankPicker(context) : null,
          onLongPress: onLongPress,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Fish icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppOverlays.primary15,
                        AppOverlays.primary8,
                      ],
                    ),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: const Icon(
                    Icons.set_meal_rounded, // Fish icon
                    color: AppColors.primary,
                    size: AppIconSizes.sm,
                  ),
                ),
                const SizedBox(width: 12),

                // Tank info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tanks[currentIndex].name,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${tanks[currentIndex].volumeLitres.toStringAsFixed(0)}L${hasMultipleTanks ? ' • ${currentIndex + 1}/${tanks.length}' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Picker indicator (only if multiple tanks)
                if (hasMultipleTanks)
                  Icon(
                    Icons.unfold_more_rounded,
                    color: AppColors.textHint,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTankPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TankPickerSheet(
        tanks: tanks,
        currentIndex: currentIndex,
        onSelected: (index) {
          onChanged(index);
          Navigator.pop(ctx);
        },
        onAddTank: () {
          Navigator.pop(ctx);
          onAddTank();
        },
      ),
    );
  }
}
