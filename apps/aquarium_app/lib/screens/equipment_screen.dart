import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

class EquipmentScreen extends ConsumerWidget {
  final String tankId;

  const EquipmentScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(equipmentProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (equipment) {
          if (equipment.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No equipment yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Add filters, heaters, lights...', style: AppTypography.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Equipment'),
                  ),
                ],
              ),
            );
          }

          final overdue = equipment.where((e) => e.isMaintenanceOverdue).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              if (overdue > 0)
                Card(
                  color: AppColors.warning.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.warning, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$overdue maintenance overdue', style: AppTypography.labelLarge),
                              Text('Check equipment below', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (overdue > 0) const SizedBox(height: 16),

              // List
              ...equipment.map((e) => _EquipmentCard(
                equipment: e,
                onEdit: () => _showEditDialog(context, ref, e),
                onService: () => _markServiced(context, ref, e),
                onDelete: () => _confirmDelete(context, ref, e),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEquipmentSheet(tankId: tankId, ref: ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Equipment equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEquipmentSheet(tankId: tankId, ref: ref, existing: equipment),
    );
  }

  Future<void> _markServiced(BuildContext context, WidgetRef ref, Equipment equipment) async {
    final storage = ref.read(storageServiceProvider);
    final updated = equipment.copyWith(
      lastServiced: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await storage.saveEquipment(updated);
    ref.invalidate(equipmentProvider(tankId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${equipment.name} marked as serviced'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Equipment equipment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Equipment?'),
        content: Text('Remove ${equipment.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(storageServiceProvider).deleteEquipment(equipment.id);
              ref.invalidate(equipmentProvider(tankId));
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onEdit;
  final VoidCallback onService;
  final VoidCallback onDelete;

  const _EquipmentCard({
    required this.equipment,
    required this.onEdit,
    required this.onService,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = equipment.isMaintenanceOverdue;
    final daysUntil = equipment.daysUntilMaintenance;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isOverdue ? AppColors.warning.withOpacity(0.05) : null,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isOverdue
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              child: Icon(
                _getIcon(equipment.type),
                color: isOverdue ? AppColors.warning : AppColors.primary,
              ),
            ),
            title: Text(equipment.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(equipment.typeName, style: AppTypography.bodySmall),
                if (equipment.maintenanceIntervalDays != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    daysUntil != null
                        ? (daysUntil < 0
                            ? '${-daysUntil}d overdue'
                            : (daysUntil == 0 ? 'Due today' : 'Due in ${daysUntil}d'))
                        : 'Service every ${equipment.maintenanceIntervalDays}d',
                    style: TextStyle(
                      color: isOverdue ? AppColors.warning : AppColors.textSecondary,
                      fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (_) => [
                if (equipment.maintenanceIntervalDays != null)
                  const PopupMenuItem(value: 'service', child: Text('Mark Serviced')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Remove')),
              ],
              onSelected: (value) {
                if (value == 'service') onService();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
            onTap: onEdit,
          ),
          if (equipment.lastServiced != null)
            Padding(
              padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.history, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Last serviced ${DateFormat('MMM d').format(equipment.lastServiced!)}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.filter: return Icons.filter_alt;
      case EquipmentType.heater: return Icons.thermostat;
      case EquipmentType.light: return Icons.light_mode;
      case EquipmentType.airPump: return Icons.air;
      case EquipmentType.co2System: return Icons.bubble_chart;
      case EquipmentType.autoFeeder: return Icons.restaurant;
      case EquipmentType.thermometer: return Icons.device_thermostat;
      case EquipmentType.wavemaker: return Icons.waves;
      case EquipmentType.skimmer: return Icons.filter_drama;
      case EquipmentType.other: return Icons.settings;
    }
  }
}

class _AddEquipmentSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;
  final Equipment? existing;

  const _AddEquipmentSheet({required this.tankId, required this.ref, this.existing});

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _intervalController;
  late EquipmentType _type;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _brandController = TextEditingController(text: widget.existing?.brand ?? '');
    _intervalController = TextEditingController(
      text: widget.existing?.maintenanceIntervalDays?.toString() ?? '',
    );
    _type = widget.existing?.type ?? EquipmentType.filter;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing != null ? 'Edit Equipment' : 'Add Equipment',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Type selector
            Text('Type', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EquipmentType.values.map((type) {
                final isSelected = _type == type;
                return ChoiceChip(
                  label: Text(_getTypeName(type)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _type = type),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g., Fluval 307',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand (optional)',
                hintText: 'e.g., Fluval',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: 'Maintenance interval (days)',
                hintText: 'e.g., 30',
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.existing != null ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(EquipmentType type) {
    switch (type) {
      case EquipmentType.filter: return 'Filter';
      case EquipmentType.heater: return 'Heater';
      case EquipmentType.light: return 'Light';
      case EquipmentType.airPump: return 'Air Pump';
      case EquipmentType.co2System: return 'CO₂';
      case EquipmentType.autoFeeder: return 'Feeder';
      case EquipmentType.thermometer: return 'Thermo';
      case EquipmentType.wavemaker: return 'Wave';
      case EquipmentType.skimmer: return 'Skimmer';
      case EquipmentType.other: return 'Other';
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
      final now = DateTime.now();
      final interval = int.tryParse(_intervalController.text);

      final equipment = Equipment(
        id: widget.existing?.id ?? _uuid.v4(),
        tankId: widget.tankId,
        type: _type,
        name: name,
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        maintenanceIntervalDays: interval,
        lastServiced: widget.existing?.lastServiced ?? (interval != null ? now : null),
        installedDate: widget.existing?.installedDate ?? now,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      await storage.saveEquipment(equipment);
      widget.ref.invalidate(equipmentProvider(widget.tankId));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
