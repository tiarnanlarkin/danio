import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class TankComparisonScreen extends ConsumerStatefulWidget {
  const TankComparisonScreen({super.key});

  @override
  ConsumerState<TankComparisonScreen> createState() => _TankComparisonScreenState();
}

class _TankComparisonScreenState extends ConsumerState<TankComparisonScreen> {
  String? _tank1Id;
  String? _tank2Id;

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Tanks')),
      body: tanksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tanks) {
          if (tanks.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.compare, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('Need at Least 2 Tanks', style: AppTypography.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Add another tank to compare them side by side.',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final tank1 = _tank1Id != null ? tanks.firstWhere((t) => t.id == _tank1Id, orElse: () => tanks[0]) : tanks[0];
          final tank2 = _tank2Id != null ? tanks.firstWhere((t) => t.id == _tank2Id, orElse: () => tanks[1]) : tanks[1];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tank selectors
              Row(
                children: [
                  Expanded(
                    child: _TankSelector(
                      tanks: tanks,
                      selectedId: tank1.id,
                      onChanged: (id) => setState(() => _tank1Id = id),
                      excludeId: tank2.id,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.compare_arrows),
                  ),
                  Expanded(
                    child: _TankSelector(
                      tanks: tanks,
                      selectedId: tank2.id,
                      onChanged: (id) => setState(() => _tank2Id = id),
                      excludeId: tank1.id,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Comparison table
              _ComparisonSection(
                title: 'Basic Info',
                rows: [
                  _ComparisonRow(label: 'Name', value1: tank1.name, value2: tank2.name),
                  _ComparisonRow(label: 'Volume', value1: '${tank1.volumeLitres.toStringAsFixed(0)} L', value2: '${tank2.volumeLitres.toStringAsFixed(0)} L'),
                  _ComparisonRow(label: 'Type', value1: tank1.tankType, value2: tank2.tankType),
                  _ComparisonRow(label: 'Status', value1: tank1.cyclingComplete ? 'Cycled' : 'Cycling', value2: tank2.cyclingComplete ? 'Cycled' : 'Cycling'),
                ],
              ),

              _ComparisonSection(
                title: 'Livestock',
                rows: [
                  _ComparisonRow(
                    label: 'Fish',
                    value1: '${tank1.livestock.where((l) => l.type == 'fish').fold(0, (sum, l) => sum + l.quantity)}',
                    value2: '${tank2.livestock.where((l) => l.type == 'fish').fold(0, (sum, l) => sum + l.quantity)}',
                  ),
                  _ComparisonRow(
                    label: 'Invertebrates',
                    value1: '${tank1.livestock.where((l) => l.type == 'invertebrate').fold(0, (sum, l) => sum + l.quantity)}',
                    value2: '${tank2.livestock.where((l) => l.type == 'invertebrate').fold(0, (sum, l) => sum + l.quantity)}',
                  ),
                  _ComparisonRow(
                    label: 'Species',
                    value1: '${tank1.livestock.length}',
                    value2: '${tank2.livestock.length}',
                  ),
                ],
              ),

              _ComparisonSection(
                title: 'Plants',
                rows: [
                  _ComparisonRow(
                    label: 'Total Plants',
                    value1: '${tank1.plants.fold(0, (sum, p) => sum + p.quantity)}',
                    value2: '${tank2.plants.fold(0, (sum, p) => sum + p.quantity)}',
                  ),
                  _ComparisonRow(
                    label: 'Species',
                    value1: '${tank1.plants.length}',
                    value2: '${tank2.plants.length}',
                  ),
                ],
              ),

              // Latest parameters comparison
              Consumer(
                builder: (ctx, ref, _) {
                  final params1 = ref.watch(latestParametersProvider(tank1.id));
                  final params2 = ref.watch(latestParametersProvider(tank2.id));

                  return params1.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (p1) => params2.when(
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                      data: (p2) {
                        if (p1 == null && p2 == null) return const SizedBox();

                        return _ComparisonSection(
                          title: 'Latest Parameters',
                          rows: [
                            if (p1?.temperature != null || p2?.temperature != null)
                              _ComparisonRow(
                                label: 'Temperature',
                                value1: p1?.temperature != null ? '${p1!.temperature!.toStringAsFixed(1)}°C' : '-',
                                value2: p2?.temperature != null ? '${p2!.temperature!.toStringAsFixed(1)}°C' : '-',
                              ),
                            if (p1?.ph != null || p2?.ph != null)
                              _ComparisonRow(
                                label: 'pH',
                                value1: p1?.ph?.toStringAsFixed(1) ?? '-',
                                value2: p2?.ph?.toStringAsFixed(1) ?? '-',
                              ),
                            if (p1?.ammonia != null || p2?.ammonia != null)
                              _ComparisonRow(
                                label: 'Ammonia',
                                value1: p1?.ammonia != null ? '${p1!.ammonia!.toStringAsFixed(2)} ppm' : '-',
                                value2: p2?.ammonia != null ? '${p2!.ammonia!.toStringAsFixed(2)} ppm' : '-',
                              ),
                            if (p1?.nitrite != null || p2?.nitrite != null)
                              _ComparisonRow(
                                label: 'Nitrite',
                                value1: p1?.nitrite != null ? '${p1!.nitrite!.toStringAsFixed(2)} ppm' : '-',
                                value2: p2?.nitrite != null ? '${p2!.nitrite!.toStringAsFixed(2)} ppm' : '-',
                              ),
                            if (p1?.nitrate != null || p2?.nitrate != null)
                              _ComparisonRow(
                                label: 'Nitrate',
                                value1: p1?.nitrate != null ? '${p1!.nitrate!.toStringAsFixed(0)} ppm' : '-',
                                value2: p2?.nitrate != null ? '${p2!.nitrate!.toStringAsFixed(0)} ppm' : '-',
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}

class _TankSelector extends StatelessWidget {
  final List<Tank> tanks;
  final String selectedId;
  final Function(String) onChanged;
  final String excludeId;

  const _TankSelector({
    required this.tanks,
    required this.selectedId,
    required this.onChanged,
    required this.excludeId,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: tanks
          .where((t) => t.id != excludeId)
          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final String title;
  final List<_ComparisonRow> rows;

  const _ComparisonSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelLarge),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value1;
  final String value2;

  const _ComparisonRow({
    required this.label,
    required this.value1,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(
            child: Text(
              value1,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value2,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
