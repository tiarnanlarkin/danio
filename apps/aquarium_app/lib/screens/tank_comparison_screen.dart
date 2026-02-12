import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class TankComparisonScreen extends ConsumerStatefulWidget {
  const TankComparisonScreen({super.key});

  @override
  ConsumerState<TankComparisonScreen> createState() =>
      _TankComparisonScreenState();
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
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Need at Least 2 Tanks',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
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

          final tank1 = _tank1Id != null
              ? tanks.firstWhere(
                  (t) => t.id == _tank1Id,
                  orElse: () => tanks[0],
                )
              : tanks[0];
          final tank2 = _tank2Id != null
              ? tanks.firstWhere(
                  (t) => t.id == _tank2Id,
                  orElse: () => tanks[1],
                )
              : tanks[1];

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

              const SizedBox(height: AppSpacing.lg),

              // Comparison table
              _ComparisonSection(
                title: 'Basic Info',
                rows: [
                  _ComparisonRow(
                    label: 'Name',
                    value1: tank1.name,
                    value2: tank2.name,
                  ),
                  _ComparisonRow(
                    label: 'Volume',
                    value1: '${tank1.volumeLitres.toStringAsFixed(0)} L',
                    value2: '${tank2.volumeLitres.toStringAsFixed(0)} L',
                  ),
                  _ComparisonRow(
                    label: 'Type',
                    value1: tank1.type.name,
                    value2: tank2.type.name,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),
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
          .map(
            (t) => DropdownMenuItem(
              value: t.id,
              child: Text(t.name, overflow: TextOverflow.ellipsis),
            ),
          )
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
