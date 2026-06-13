import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../services/tank_comparison_service.dart';
import '../services/tank_health_service.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_states.dart';
import '../widgets/core/bubble_loader.dart';

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
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => AppErrorState(
          message: "Couldn't load your tanks. Tap to try again.",
          onRetry: () => ref.invalidate(tanksProvider),
        ),
        data: (tanks) {
          if (tanks.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.compare,
                      size: AppIconSizes.xxl,
                      color: context.textHint,
                    ),
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

          return _ComparisonDataView(
            allTanks: tanks,
            selectedTanks: [tank1, tank2],
            selectors: Row(
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
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
          );
        },
      ),
    );
  }
}

class _ComparisonDataView extends ConsumerWidget {
  const _ComparisonDataView({
    required this.allTanks,
    required this.selectedTanks,
    required this.selectors,
  });

  final List<Tank> allTanks;
  final List<Tank> selectedTanks;
  final Widget selectors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = <TankComparisonSummary>[];
    var isLoading = false;
    Object? firstError;

    for (final tank in allTanks) {
      final logs = ref.watch(allLogsProvider(tank.id));
      final tasks = ref.watch(tasksProvider(tank.id));
      final livestock = ref.watch(livestockProvider(tank.id));
      final equipment = ref.watch(equipmentProvider(tank.id));

      final values = [logs, tasks, livestock, equipment];
      if (values.any((value) => value.isLoading)) {
        isLoading = true;
        continue;
      }
      firstError ??= values
          .map((value) => value.error)
          .whereType<Object>()
          .firstOrNull;
      if (firstError != null) continue;

      summaries.add(
        TankComparisonService.buildSummary(
          tank: tank,
          logs: logs.value ?? const [],
          tasks: tasks.value ?? const [],
          livestock: livestock.value ?? const [],
          equipment: equipment.value ?? const [],
        ),
      );
    }

    if (firstError != null) {
      return Center(
        child: AppErrorState(
          message: "Couldn't load comparison data. Tap to try again.",
          onRetry: () {
            for (final tank in allTanks) {
              ref.invalidate(allLogsProvider(tank.id));
              ref.invalidate(tasksProvider(tank.id));
              ref.invalidate(livestockProvider(tank.id));
              ref.invalidate(equipmentProvider(tank.id));
            }
          },
        ),
      );
    }

    if (isLoading || summaries.length < allTanks.length) {
      return const Center(child: BubbleLoader(message: 'Comparing tanks...'));
    }

    final summariesByTankId = {
      for (final summary in summaries) summary.tank.id: summary,
    };
    final selectedSummaries = selectedTanks
        .map((tank) => summariesByTankId[tank.id])
        .whereType<TankComparisonSummary>()
        .toList();
    final needsAttention = TankComparisonService.chooseNeedsAttentionFirst(
      summaries,
    );

    final items = <Widget>[
      selectors,
      const SizedBox(height: AppSpacing.lg),
      if (summaries.length > 2) _AllTanksPriorityCard(summaries: summaries),
      if (summaries.length > 2) const SizedBox(height: AppSpacing.md),
      if (needsAttention != null) _InsightCard(summary: needsAttention),
      const SizedBox(height: AppSpacing.md),
      ...selectedSummaries.map((summary) => _SummaryCard(summary: summary)),
      const SizedBox(height: AppSpacing.sm),
      _ComparisonSection(
        title: 'Water',
        icon: Icons.water_drop,
        children: selectedSummaries
            .map((summary) => _WaterSummary(summary: summary))
            .toList(),
      ),
      _ComparisonSection(
        title: 'Care rhythm',
        icon: Icons.event_available,
        children: selectedSummaries
            .map((summary) => _CareSummary(summary: summary))
            .toList(),
      ),
      _ComparisonSection(
        title: 'Livestock & stocking',
        icon: Icons.set_meal,
        children: selectedSummaries
            .map((summary) => _LivestockSummary(summary: summary))
            .toList(),
      ),
      _ComparisonSection(
        title: 'Equipment',
        icon: Icons.filter_alt,
        children: selectedSummaries
            .map((summary) => _EquipmentSummary(summary: summary))
            .toList(),
      ),
      _ComparisonSection(
        title: 'Activity',
        icon: Icons.history,
        children: selectedSummaries
            .map((summary) => _ActivitySummary(summary: summary))
            .toList(),
      ),
      const SizedBox(height: AppSpacing.xxl),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemBuilder: (context, index) => items[index],
      itemCount: items.length,
    );
  }
}

class _AllTanksPriorityCard extends StatelessWidget {
  const _AllTanksPriorityCard({required this.summaries});

  final List<TankComparisonSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final sorted = [...summaries]
      ..sort((a, b) => b.attentionScore.compareTo(a.attentionScore));
    final top = sorted.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard_customize, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('All tanks at a glance', style: AppTypography.labelLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Highest priority: ${top.tank.name}',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(top.primaryReason, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            ...sorted.take(5).map((summary) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HealthChip(summary: summary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.tank.name,
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs2),
                          Text(
                            summary.primaryReason,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.warningAlpha10,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text('Needs attention first', style: AppTypography.labelLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(summary.tank.name, style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(summary.primaryReason, style: AppTypography.bodyMedium),
            if (summary.attentionReasons.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              ...summary.attentionReasons
                  .skip(1)
                  .take(3)
                  .map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('- '),
                          Expanded(
                            child: Text(reason, style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.tank.name,
                    style: AppTypography.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _HealthChip(summary: summary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetricPill(
                  icon: Icons.water_drop,
                  label: summary.waterStatusLabel,
                ),
                _MetricPill(
                  icon: Icons.event_available,
                  label: summary.maintenanceStatusLabel,
                ),
                _MetricPill(
                  icon: Icons.set_meal,
                  label:
                      '${summary.livestockCount} livestock across ${summary.livestockSpeciesCount} species',
                ),
                _MetricPill(
                  icon: Icons.filter_alt,
                  label:
                      '${summary.equipmentCount} equipment item${summary.equipmentCount == 1 ? '' : 's'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = switch (summary.health.level) {
      TankHealthLevel.excellent => AppColors.success,
      TankHealthLevel.good => AppColors.warning,
      TankHealthLevel.fair => DanioColors.coralAccent,
      TankHealthLevel.poor => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        '${summary.health.score}/100 ${summary.health.label}',
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.xs, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon),
        title: Text(title, style: AppTypography.labelLarge),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: children,
      ),
    );
  }
}

class _WaterSummary extends StatelessWidget {
  const _WaterSummary({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    final test = summary.latestWaterTest;
    return _TankSectionBlock(
      tankName: summary.tank.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.waterStatusLabel, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          if (test == null)
            Text(
              'No water tests yet. Add a test to unlock parameter trends.',
              style: AppTypography.bodySmall,
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ValueChip(label: 'pH', value: _format(test.ph, 1)),
                _ValueChip(label: 'NH3', value: _format(test.ammonia, 2)),
                _ValueChip(label: 'NO2', value: _format(test.nitrite, 2)),
                _ValueChip(label: 'NO3', value: _format(test.nitrate, 0)),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: summary.trendSummaries.map((trend) {
              return _ValueChip(
                label: trend.label,
                value: '${trend.currentValue} (${trend.directionLabel})',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CareSummary extends StatelessWidget {
  const _CareSummary({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    return _TankSectionBlock(
      tankName: summary.tank.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactRow(
            label: 'Water changes',
            value: '${summary.waterChangeCount} logged',
          ),
          _FactRow(label: 'Maintenance', value: summary.maintenanceStatusLabel),
          _FactRow(
            label: 'Overdue tasks',
            value: '${summary.overdueTaskCount}',
          ),
          _FactRow(label: 'Due today', value: '${summary.dueTodayTaskCount}'),
        ],
      ),
    );
  }
}

class _LivestockSummary extends StatelessWidget {
  const _LivestockSummary({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    final noLivestock = summary.livestockCount == 0;
    return _TankSectionBlock(
      tankName: summary.tank.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (noLivestock)
            Text('No livestock yet', style: AppTypography.bodyMedium)
          else
            _FactRow(
              label: 'Livestock',
              value:
                  '${summary.livestockCount} across ${summary.livestockSpeciesCount} species',
            ),
          _FactRow(
            label: 'Stocking',
            value:
                '${summary.stocking.level.name} (${summary.stocking.percentFull.toStringAsFixed(0)}%)',
          ),
          Text(summary.stocking.summary, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _EquipmentSummary extends StatelessWidget {
  const _EquipmentSummary({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    return _TankSectionBlock(
      tankName: summary.tank.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactRow(
            label: 'Items',
            value: '${summary.equipmentCount} registered',
          ),
          _FactRow(
            label: 'Maintenance overdue',
            value: '${summary.overdueEquipmentCount}',
          ),
        ],
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.summary});

  final TankComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    return _TankSectionBlock(
      tankName: summary.tank.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactRow(label: 'Age', value: _ageLabel(summary.ageDays)),
          _FactRow(
            label: 'Recent activity',
            value: summary.activityStatusLabel,
          ),
          _FactRow(
            label: 'Water tests',
            value: '${summary.waterTestCount} logged',
          ),
          if (summary.latestActivityAt != null)
            _FactRow(
              label: 'Last log',
              value: DateFormat('d MMM y').format(summary.latestActivityAt!),
            ),
        ],
      ),
    );
  }
}

class _TankSectionBlock extends StatelessWidget {
  const _TankSectionBlock({required this.tankName, required this.child});

  final String tankName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tankName, style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Text('$label: $value', style: AppTypography.bodySmall),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

String _format(double? value, int decimals) =>
    value == null ? '-' : value.toStringAsFixed(decimals);

String _ageLabel(int days) {
  if (days < 30) return '$days days';
  final months = (days / 30).floor();
  if (months < 12) return '$months month${months == 1 ? '' : 's'}';
  final years = (months / 12).floor();
  final remainingMonths = months % 12;
  if (remainingMonths == 0) return '$years year${years == 1 ? '' : 's'}';
  return '$years year${years == 1 ? '' : 's'}, $remainingMonths month${remainingMonths == 1 ? '' : 's'}';
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
      initialValue: selectedId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.sm,
        ),
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
