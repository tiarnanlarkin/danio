import 'package:collection/collection.dart';

import '../models/models.dart';
import 'stocking_calculator.dart';
import 'tank_health_service.dart';

class TankComparisonSummary {
  const TankComparisonSummary({
    required this.tank,
    required this.health,
    required this.stocking,
    required this.latestWaterTest,
    required this.latestWaterTestAt,
    required this.latestActivityAt,
    required this.ageDays,
    required this.waterTestCount,
    required this.waterChangeCount,
    required this.overdueTaskCount,
    required this.dueTodayTaskCount,
    required this.livestockCount,
    required this.livestockSpeciesCount,
    required this.equipmentCount,
    required this.overdueEquipmentCount,
    required this.attentionScore,
    required this.primaryReason,
    required this.attentionReasons,
    required this.waterStatusLabel,
    required this.maintenanceStatusLabel,
    required this.activityStatusLabel,
    required this.trendSummaries,
  });

  final Tank tank;
  final TankHealthScore health;
  final StockingResult stocking;
  final WaterTestResults? latestWaterTest;
  final DateTime? latestWaterTestAt;
  final DateTime? latestActivityAt;
  final int ageDays;
  final int waterTestCount;
  final int waterChangeCount;
  final int overdueTaskCount;
  final int dueTodayTaskCount;
  final int livestockCount;
  final int livestockSpeciesCount;
  final int equipmentCount;
  final int overdueEquipmentCount;
  final int attentionScore;
  final String primaryReason;
  final List<String> attentionReasons;
  final String waterStatusLabel;
  final String maintenanceStatusLabel;
  final String activityStatusLabel;
  final List<ParameterTrendSummary> trendSummaries;
}

class ParameterTrendSummary {
  const ParameterTrendSummary({
    required this.label,
    required this.currentValue,
    required this.directionLabel,
  });

  final String label;
  final String currentValue;
  final String directionLabel;
}

class TankComparisonService {
  static TankComparisonSummary buildSummary({
    required Tank tank,
    required List<LogEntry> logs,
    required List<Task> tasks,
    required List<Livestock> livestock,
    required List<Equipment> equipment,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final sortedLogs = [...logs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final waterTests = sortedLogs
        .where(
          (l) => l.type == LogType.waterTest && l.waterTest?.hasValues == true,
        )
        .toList();
    final waterChanges = sortedLogs
        .where((l) => l.type == LogType.waterChange)
        .toList();
    final latestWaterTest = waterTests.firstOrNull;
    final latestActivity = sortedLogs.firstOrNull;
    final overdueTasks = tasks.where((t) => _isOverdue(t, clock)).length;
    final dueTodayTasks = tasks.where((t) => _isDueToday(t, clock)).length;
    final overdueEquipment = equipment
        .where((e) => e.isMaintenanceOverdue)
        .length;
    final health = TankHealthService.calculateScore(tank: tank, logs: logs);
    final stocking = StockingCalculator.calculate(
      tank: tank,
      livestock: livestock,
    );

    final reasons = <String>[];
    var attentionScore = (100 - health.score).clamp(0, 100);

    if (overdueTasks > 0) {
      attentionScore += overdueTasks * 18;
      reasons.add(
        '$overdueTasks overdue task${overdueTasks == 1 ? '' : 's'} needs attention',
      );
    } else if (dueTodayTasks > 0) {
      attentionScore += dueTodayTasks * 8;
      reasons.add(
        '$dueTodayTasks task${dueTodayTasks == 1 ? '' : 's'} due today',
      );
    }

    final waterReason = _waterAttentionReason(tank, latestWaterTest, clock);
    if (waterReason != null) {
      attentionScore += waterReason.score;
      reasons.add(waterReason.label);
    }

    final latestChange = waterChanges.firstOrNull;
    if (latestChange == null) {
      attentionScore += 12;
      reasons.add('No water changes logged yet');
    } else {
      final days = _daysBetween(latestChange.timestamp, clock);
      if (days > 14) {
        attentionScore += 15;
        reasons.add('Water change very overdue');
      } else if (days > 10) {
        attentionScore += 10;
        reasons.add('Water change overdue');
      } else if (days > 7) {
        attentionScore += 5;
        reasons.add('Water change due soon');
      }
    }

    switch (stocking.level) {
      case StockingLevel.overstocked:
        attentionScore += 18;
        reasons.add('Stocking level is over capacity');
      case StockingLevel.heavy:
        attentionScore += 10;
        reasons.add('Heavy stocking needs close maintenance');
      case StockingLevel.moderate:
        attentionScore += 4;
      case StockingLevel.good:
      case StockingLevel.understocked:
        break;
    }

    if (overdueEquipment > 0) {
      attentionScore += overdueEquipment * 8;
      reasons.add(
        '$overdueEquipment equipment item${overdueEquipment == 1 ? '' : 's'} overdue for maintenance',
      );
    }

    if (latestActivity == null) {
      attentionScore += 8;
      reasons.add('No activity logged yet');
    }

    final primaryReason = reasons.isNotEmpty
        ? reasons.first
        : 'This tank looks steady based on current logs';

    return TankComparisonSummary(
      tank: tank,
      health: health,
      stocking: stocking,
      latestWaterTest: latestWaterTest?.waterTest,
      latestWaterTestAt: latestWaterTest?.timestamp,
      latestActivityAt: latestActivity?.timestamp,
      ageDays: _daysBetween(tank.startDate, clock).clamp(0, 99999),
      waterTestCount: waterTests.length,
      waterChangeCount: waterChanges.length,
      overdueTaskCount: overdueTasks,
      dueTodayTaskCount: dueTodayTasks,
      livestockCount: livestock.fold<int>(0, (sum, item) => sum + item.count),
      livestockSpeciesCount: livestock.length,
      equipmentCount: equipment.length,
      overdueEquipmentCount: overdueEquipment,
      attentionScore: attentionScore.clamp(0, 200),
      primaryReason: primaryReason,
      attentionReasons: reasons,
      waterStatusLabel: _waterStatusLabel(latestWaterTest, clock),
      maintenanceStatusLabel: _maintenanceStatusLabel(latestChange, clock),
      activityStatusLabel: _activityStatusLabel(latestActivity, clock),
      trendSummaries: _buildTrendSummaries(waterTests),
    );
  }

  static TankComparisonSummary? chooseNeedsAttentionFirst(
    List<TankComparisonSummary> summaries,
  ) {
    if (summaries.isEmpty) return null;
    return summaries.reduce(
      (current, next) =>
          next.attentionScore > current.attentionScore ? next : current,
    );
  }

  static bool _isOverdue(Task task, DateTime now) {
    if (task.dueDate == null || !task.isEnabled) return false;
    return now.isAfter(task.dueDate!);
  }

  static bool _isDueToday(Task task, DateTime now) {
    if (task.dueDate == null || !task.isEnabled) return false;
    final due = task.dueDate!;
    return due.year == now.year && due.month == now.month && due.day == now.day;
  }

  static _AttentionReason? _waterAttentionReason(
    Tank tank,
    LogEntry? latestWaterTest,
    DateTime now,
  ) {
    if (latestWaterTest == null || latestWaterTest.waterTest == null) {
      return const _AttentionReason('No water tests logged yet', 18);
    }

    final daysSinceTest = _daysBetween(latestWaterTest.timestamp, now);
    if (daysSinceTest > 14) {
      return const _AttentionReason('Water test is stale', 12);
    }

    final test = latestWaterTest.waterTest!;
    final danger = <String>[];
    if ((test.ammonia ?? 0) >= 0.5) danger.add('ammonia');
    if ((test.nitrite ?? 0) >= 0.5) danger.add('nitrite');
    if ((test.nitrate ?? 0) >= 80) danger.add('nitrate');
    if (test.ph != null) {
      final min = tank.targets.phMin;
      final max = tank.targets.phMax;
      if ((min != null && test.ph! < min - 0.5) ||
          (max != null && test.ph! > max + 0.5)) {
        danger.add('pH');
      }
    }

    if (danger.isNotEmpty) {
      return _AttentionReason(
        'Water parameters need attention: ${danger.join(', ')}',
        20,
      );
    }

    final warning = <String>[];
    if ((test.ammonia ?? 0) > 0) warning.add('ammonia');
    if ((test.nitrite ?? 0) > 0) warning.add('nitrite');
    if ((test.nitrate ?? 0) > 40) warning.add('nitrate');
    if (warning.isNotEmpty) {
      return _AttentionReason(
        'Water parameters are drifting: ${warning.join(', ')}',
        10,
      );
    }

    return null;
  }

  static String _waterStatusLabel(LogEntry? latestWaterTest, DateTime now) {
    if (latestWaterTest == null) return 'No water tests';
    final days = _daysBetween(latestWaterTest.timestamp, now);
    if (days == 0) return 'Water tested today';
    if (days == 1) return 'Water tested yesterday';
    if (days > 14) return 'Water test stale';
    return 'Water tested $days days ago';
  }

  static String _maintenanceStatusLabel(LogEntry? latestChange, DateTime now) {
    if (latestChange == null) return 'No water changes';
    final days = _daysBetween(latestChange.timestamp, now);
    if (days == 0) return 'Water changed today';
    if (days == 1) return 'Water changed yesterday';
    if (days > 14) return 'Water change very overdue';
    if (days > 7) return 'Water change due';
    return 'Water changed $days days ago';
  }

  static String _activityStatusLabel(LogEntry? latestActivity, DateTime now) {
    if (latestActivity == null) return 'No activity yet';
    final days = _daysBetween(latestActivity.timestamp, now);
    if (days == 0) return 'Activity today';
    if (days == 1) return 'Activity yesterday';
    return 'Activity $days days ago';
  }

  static List<ParameterTrendSummary> _buildTrendSummaries(
    List<LogEntry> waterTests,
  ) {
    final ordered = [...waterTests]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return [
      _trendFor('pH', ordered, (t) => t.ph, decimals: 1),
      _trendFor('NH3', ordered, (t) => t.ammonia, decimals: 2),
      _trendFor('NO2', ordered, (t) => t.nitrite, decimals: 2),
      _trendFor('NO3', ordered, (t) => t.nitrate, decimals: 0),
      _trendFor('Temp', ordered, (t) => t.temperature, decimals: 1, unit: 'C'),
    ];
  }

  static ParameterTrendSummary _trendFor(
    String label,
    List<LogEntry> tests,
    double? Function(WaterTestResults test) valueFor, {
    required int decimals,
    String? unit,
  }) {
    final values = tests
        .map((log) => log.waterTest)
        .whereType<WaterTestResults>()
        .map(valueFor)
        .whereType<double>()
        .toList();

    if (values.isEmpty) {
      return ParameterTrendSummary(
        label: label,
        currentValue: '-',
        directionLabel: 'No data',
      );
    }

    final current = values.last;
    final formatted =
        '${current.toStringAsFixed(decimals)}${unit == null ? '' : ' $unit'}';
    if (values.length < 2) {
      return ParameterTrendSummary(
        label: label,
        currentValue: formatted,
        directionLabel: 'One reading',
      );
    }

    final previous = values[values.length - 2];
    final delta = current - previous;
    final threshold = decimals == 0 ? 1.0 : 0.05;
    final direction = delta.abs() < threshold
        ? 'Stable'
        : delta > 0
        ? 'Rising'
        : 'Falling';

    return ParameterTrendSummary(
      label: label,
      currentValue: formatted,
      directionLabel: direction,
    );
  }

  static int _daysBetween(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }
}

class _AttentionReason {
  const _AttentionReason(this.label, this.score);

  final String label;
  final int score;
}
