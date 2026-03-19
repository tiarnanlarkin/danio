import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/models.dart';

/// A compact tank list tile for the bottom-plate tank switcher.
class TankListTile extends StatelessWidget {
  final String name;
  final double volumeLitres;
  final bool isSelected;
  final VoidCallback onTap;

  /// Whether to show a trailing chevron (indicates navigability).
  final bool showChevron;

  const TankListTile({
    super.key,
    required this.name,
    required this.volumeLitres,
    required this.isSelected,
    required this.onTap,
    this.showChevron = false,
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
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? context.textPrimary : context.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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
