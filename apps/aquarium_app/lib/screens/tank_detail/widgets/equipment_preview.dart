import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../theme/app_theme.dart';

class EquipmentPreview extends StatelessWidget {
  final List<Equipment> equipment;

  const EquipmentPreview({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    if (equipment.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.spacious,
          child: CompactEmptyState(
            icon: Icons.settings,
            message: 'No equipment tracked yet',
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: equipment.length,
        itemBuilder: (context, index) {
          final e = equipment[index];
          final isOverdue = e.isMaintenanceOverdue;
          return Container(
            width: 120,
            margin: EdgeInsets.only(
              right: index < equipment.length - 1 ? 12 : 0,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              color: isOverdue ? AppOverlays.warning10 : null,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getEquipmentIcon(e.type),
                      color: isOverdue ? AppColors.warning : AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      e.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(e.typeName, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getEquipmentIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.filter:
        return Icons.filter_alt;
      case EquipmentType.heater:
        return Icons.thermostat;
      case EquipmentType.light:
        return Icons.light_mode;
      case EquipmentType.airPump:
        return Icons.air;
      case EquipmentType.co2System:
        return Icons.bubble_chart;
      case EquipmentType.autoFeeder:
        return Icons.restaurant;
      case EquipmentType.thermometer:
        return Icons.device_thermostat;
      case EquipmentType.wavemaker:
        return Icons.waves;
      case EquipmentType.skimmer:
        return Icons.filter_drama;
      case EquipmentType.other:
        return Icons.settings;
    }
  }
}
