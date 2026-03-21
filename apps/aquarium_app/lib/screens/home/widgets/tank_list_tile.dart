import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// A compact tank list tile for the bottom-plate tank switcher.
class TankListTile extends StatelessWidget {
  final String name;
  final double volumeLitres;
  final bool isSelected;
  final VoidCallback onTap;

  /// Whether to show a trailing chevron (indicates navigability).
  final bool showChevron;

  /// Whether this tank is a demo/sample tank.
  final bool isDemoTank;

  const TankListTile({
    super.key,
    required this.name,
    required this.volumeLitres,
    required this.isSelected,
    required this.onTap,
    this.showChevron = false,
    this.isDemoTank = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: context.textPrimary.withAlpha(25),
      leading: Icon(
        Icons.set_meal_rounded,
        color: isSelected ? context.textPrimary : context.textSecondary,
        size: 20,
      ),
      title: Row(
        children: [
          Text(
            name,
            style: TextStyle(
              color: isSelected ? context.textPrimary : context.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isDemoTank) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.primary.withAlpha(60),
                  width: 0.5,
                ),
              ),
              child: Text(
                'Demo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${volumeLitres.toStringAsFixed(0)}L',
        style: TextStyle(
          color: context.textSecondary.withAlpha(128),
          fontSize: 12,
        ),
      ),
      trailing: showChevron
          ? Icon(Icons.chevron_right, color: context.textHint, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
