import '../../../models/models.dart';
import '../../../services/compatibility_service.dart';
import '../models/smart_models.dart';

enum AquariumIntelligenceSeverity { clear, info, warning, critical }

enum AquariumIntelligenceCategory {
  risk,
  care,
  compatibility,
  anomaly,
  equipment,
}

enum AquariumIntelligenceAction {
  none,
  emergencyGuide,
  waterTest,
  tankDetail,
  workshop,
}

class AquariumIntelligenceTankInput {
  final Tank tank;
  final List<LogEntry> logs;
  final List<Task> tasks;
  final List<Livestock> livestock;
  final List<Equipment> equipment;
  final List<Anomaly> anomalies;

  const AquariumIntelligenceTankInput({
    required this.tank,
    required this.logs,
    required this.tasks,
    required this.livestock,
    required this.equipment,
    this.anomalies = const [],
  });
}

class AquariumIntelligenceItem {
  final String tankId;
  final String tankName;
  final AquariumIntelligenceSeverity severity;
  final AquariumIntelligenceCategory category;
  final AquariumIntelligenceAction action;
  final String title;
  final String reason;
  final String actionLabel;

  const AquariumIntelligenceItem({
    required this.tankId,
    required this.tankName,
    required this.severity,
    required this.category,
    required this.action,
    required this.title,
    required this.reason,
    required this.actionLabel,
  });
}

class AquariumIntelligenceReport {
  final List<AquariumIntelligenceItem> items;
  final int tankCount;

  const AquariumIntelligenceReport({
    required this.items,
    required this.tankCount,
  });

  List<AquariumIntelligenceItem> get topItems => items.take(3).toList();

  int get criticalRiskCount => items
      .where(
        (item) =>
            item.category == AquariumIntelligenceCategory.risk &&
            item.severity == AquariumIntelligenceSeverity.critical,
      )
      .length;

  int get careActionCount => items
      .where(
        (item) =>
            item.category == AquariumIntelligenceCategory.care ||
            item.category == AquariumIntelligenceCategory.equipment,
      )
      .length;

  int get compatibilityIssueCount => items
      .where(
        (item) => item.category == AquariumIntelligenceCategory.compatibility,
      )
      .length;

  int get activeAnomalyCount => items
      .where((item) => item.category == AquariumIntelligenceCategory.anomaly)
      .length;
}

class AquariumIntelligenceService {
  static const double unsafeNitrogenThreshold = 0.25;

  const AquariumIntelligenceService._();

  static AquariumIntelligenceReport evaluate({
    required List<AquariumIntelligenceTankInput> tanks,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final items = <AquariumIntelligenceItem>[];

    for (final input in tanks) {
      final latestWaterTest = _latestWaterTest(input.logs);
      final water = latestWaterTest?.waterTest;
      if (_hasUnsafeNitrogen(water)) {
        items.add(
          AquariumIntelligenceItem(
            tankId: input.tank.id,
            tankName: input.tank.name,
            severity: AquariumIntelligenceSeverity.critical,
            category: AquariumIntelligenceCategory.risk,
            action: AquariumIntelligenceAction.emergencyGuide,
            title: 'Unsafe water detected',
            reason: _unsafeNitrogenReason(water!),
            actionLabel: 'Emergency Guide',
          ),
        );
      }

      _addWaterFreshnessItem(
        input: input,
        latestWaterTest: latestWaterTest,
        now: effectiveNow,
        items: items,
      );
      _addOverdueTaskItem(input: input, now: effectiveNow, items: items);
      _addLivestockHealthItem(input: input, items: items);
      _addCompatibilityItem(input: input, items: items);
      _addAnomalyItem(input: input, items: items);
      _addEquipmentItem(input: input, now: effectiveNow, items: items);
    }

    return AquariumIntelligenceReport(
      items: _sortItems(items),
      tankCount: tanks.length,
    );
  }

  static LogEntry? _latestWaterTest(List<LogEntry> logs) {
    final waterTests =
        logs.where((log) => log.type == LogType.waterTest).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return waterTests.isEmpty ? null : waterTests.first;
  }

  static bool _hasUnsafeNitrogen(WaterTestResults? water) {
    if (water == null) return false;
    return (water.ammonia ?? 0) > unsafeNitrogenThreshold ||
        (water.nitrite ?? 0) > unsafeNitrogenThreshold;
  }

  static void _addWaterFreshnessItem({
    required AquariumIntelligenceTankInput input,
    required LogEntry? latestWaterTest,
    required DateTime now,
    required List<AquariumIntelligenceItem> items,
  }) {
    if (latestWaterTest == null) {
      items.add(
        AquariumIntelligenceItem(
          tankId: input.tank.id,
          tankName: input.tank.name,
          severity: AquariumIntelligenceSeverity.warning,
          category: AquariumIntelligenceCategory.care,
          action: AquariumIntelligenceAction.waterTest,
          title: 'Water test due',
          reason:
              'No recent water test is logged for ${input.tank.name}; fresh parameters keep local guidance accurate.',
          actionLabel: 'Log Water Test',
        ),
      );
      return;
    }

    final ageDays = _calendarDayAge(latestWaterTest.timestamp, now);
    if (ageDays <= 7) return;

    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: AquariumIntelligenceSeverity.warning,
        category: AquariumIntelligenceCategory.care,
        action: AquariumIntelligenceAction.waterTest,
        title: 'Water test due',
        reason:
            'The last water test is $ageDays days old; fresh parameters keep local guidance accurate.',
        actionLabel: 'Log Water Test',
      ),
    );
  }

  static void _addOverdueTaskItem({
    required AquariumIntelligenceTankInput input,
    required DateTime now,
    required List<AquariumIntelligenceItem> items,
  }) {
    final overdueTasks =
        input.tasks
            .where((task) => task.isEnabled && _isOverdue(task.dueDate, now))
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    if (overdueTasks.isEmpty) return;

    final first = overdueTasks.first;
    final extraCount = overdueTasks.length - 1;
    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: AquariumIntelligenceSeverity.warning,
        category: AquariumIntelligenceCategory.care,
        action: AquariumIntelligenceAction.tankDetail,
        title: 'Care task overdue',
        reason: extraCount == 0
            ? '${first.title} is overdue.'
            : '${first.title} and $extraCount more care tasks are overdue.',
        actionLabel: 'Open Tank',
      ),
    );
  }

  static void _addLivestockHealthItem({
    required AquariumIntelligenceTankInput input,
    required List<AquariumIntelligenceItem> items,
  }) {
    final flagged = input.livestock
        .where((entry) => entry.healthStatus != HealthStatus.healthy)
        .toList();
    if (flagged.isEmpty) return;

    final first = flagged.first;
    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: AquariumIntelligenceSeverity.warning,
        category: AquariumIntelligenceCategory.risk,
        action: AquariumIntelligenceAction.tankDetail,
        title: 'Livestock health needs review',
        reason:
            '${first.commonName} is marked ${_healthStatusLabel(first.healthStatus)}.',
        actionLabel: 'Open Tank',
      ),
    );
  }

  static void _addCompatibilityItem({
    required AquariumIntelligenceTankInput input,
    required List<AquariumIntelligenceItem> items,
  }) {
    final issues = <CompatibilityIssue>[];
    for (final livestock in input.livestock) {
      issues.addAll(
        CompatibilityService.checkLivestockCompatibility(
          livestock: livestock,
          tank: input.tank,
          existingLivestock: input.livestock,
        ),
      );
    }
    if (issues.isEmpty) return;

    issues.sort(
      (a, b) =>
          _compatibilityRank(b.level).compareTo(_compatibilityRank(a.level)),
    );
    final first = issues.first;
    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: first.level == CompatibilityLevel.incompatible
            ? AquariumIntelligenceSeverity.critical
            : AquariumIntelligenceSeverity.warning,
        category: AquariumIntelligenceCategory.compatibility,
        action: AquariumIntelligenceAction.workshop,
        title: 'Compatibility needs review',
        reason: issues
            .take(3)
            .map((issue) => '${issue.title}: ${issue.description}')
            .join(' '),
        actionLabel: 'Open Checker',
      ),
    );
  }

  static void _addAnomalyItem({
    required AquariumIntelligenceTankInput input,
    required List<AquariumIntelligenceItem> items,
  }) {
    final active =
        input.anomalies.where((anomaly) => !anomaly.dismissed).toList()..sort(
          (a, b) =>
              _anomalyRank(b.severity).compareTo(_anomalyRank(a.severity)),
        );
    if (active.isEmpty) return;

    final first = active.first;
    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: first.severity == AnomalySeverity.critical
            ? AquariumIntelligenceSeverity.critical
            : AquariumIntelligenceSeverity.warning,
        category: AquariumIntelligenceCategory.anomaly,
        action: AquariumIntelligenceAction.tankDetail,
        title: 'Anomaly history needs review',
        reason: active.length == 1
            ? first.description
            : '${first.description}; ${active.length - 1} more active anomalies.',
        actionLabel: 'Review History',
      ),
    );
  }

  static void _addEquipmentItem({
    required AquariumIntelligenceTankInput input,
    required DateTime now,
    required List<AquariumIntelligenceItem> items,
  }) {
    final overdue =
        input.equipment
            .where(
              (equipment) => _isEquipmentMaintenanceOverdue(equipment, now),
            )
            .toList()
          ..sort(
            (a, b) => _equipmentMaintenanceDueDate(
              a,
            )!.compareTo(_equipmentMaintenanceDueDate(b)!),
          );

    if (overdue.isNotEmpty) {
      final first = overdue.first;
      items.add(
        AquariumIntelligenceItem(
          tankId: input.tank.id,
          tankName: input.tank.name,
          severity: AquariumIntelligenceSeverity.warning,
          category: AquariumIntelligenceCategory.equipment,
          action: AquariumIntelligenceAction.tankDetail,
          title: 'Equipment maintenance overdue',
          reason:
              '${first.typeName} "${first.name}" is past its maintenance interval.',
          actionLabel: 'Open Tank',
        ),
      );
      return;
    }

    final hasFilter = input.equipment.any(
      (equipment) => equipment.type == EquipmentType.filter,
    );
    if (hasFilter) return;

    items.add(
      AquariumIntelligenceItem(
        tankId: input.tank.id,
        tankName: input.tank.name,
        severity: AquariumIntelligenceSeverity.info,
        category: AquariumIntelligenceCategory.equipment,
        action: AquariumIntelligenceAction.tankDetail,
        title: 'Add filter details',
        reason:
            'Filter details are not registered yet; adding them improves local care reminders.',
        actionLabel: 'Open Tank',
      ),
    );
  }

  static String _unsafeNitrogenReason(WaterTestResults water) {
    final parts = <String>[];
    if ((water.ammonia ?? 0) > unsafeNitrogenThreshold) {
      parts.add('Ammonia ${water.ammonia!.toStringAsFixed(2)} ppm');
    }
    if ((water.nitrite ?? 0) > unsafeNitrogenThreshold) {
      parts.add('Nitrite ${water.nitrite!.toStringAsFixed(2)} ppm');
    }
    return '${parts.join(' and ')} is above the safe emergency threshold.';
  }

  static List<AquariumIntelligenceItem> _sortItems(
    List<AquariumIntelligenceItem> items,
  ) {
    final sorted = [...items]
      ..sort((a, b) {
        final severityCompare = _severityRank(
          b.severity,
        ).compareTo(_severityRank(a.severity));
        if (severityCompare != 0) return severityCompare;
        final categoryCompare = _categoryRank(
          b.category,
        ).compareTo(_categoryRank(a.category));
        if (categoryCompare != 0) return categoryCompare;
        return a.title.compareTo(b.title);
      });
    return sorted;
  }

  static int _severityRank(AquariumIntelligenceSeverity severity) {
    return switch (severity) {
      AquariumIntelligenceSeverity.critical => 3,
      AquariumIntelligenceSeverity.warning => 2,
      AquariumIntelligenceSeverity.info => 1,
      AquariumIntelligenceSeverity.clear => 0,
    };
  }

  static int _categoryRank(AquariumIntelligenceCategory category) {
    return switch (category) {
      AquariumIntelligenceCategory.risk => 5,
      AquariumIntelligenceCategory.anomaly => 4,
      AquariumIntelligenceCategory.care => 3,
      AquariumIntelligenceCategory.compatibility => 2,
      AquariumIntelligenceCategory.equipment => 1,
    };
  }

  static int _compatibilityRank(CompatibilityLevel level) {
    return switch (level) {
      CompatibilityLevel.incompatible => 2,
      CompatibilityLevel.warning => 1,
      CompatibilityLevel.compatible => 0,
    };
  }

  static int _anomalyRank(AnomalySeverity severity) {
    return switch (severity) {
      AnomalySeverity.critical => 2,
      AnomalySeverity.alert => 1,
      AnomalySeverity.warning => 0,
    };
  }

  static int _calendarDayAge(DateTime timestamp, DateTime now) {
    final testDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(testDay).inDays;
  }

  static bool _isOverdue(DateTime? dueDate, DateTime now) {
    if (dueDate == null) return false;
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return dueDay.isBefore(today);
  }

  static bool _isEquipmentMaintenanceOverdue(
    Equipment equipment,
    DateTime now,
  ) {
    final dueDate = _equipmentMaintenanceDueDate(equipment);
    if (dueDate == null) return false;
    return dueDate.isBefore(now);
  }

  static DateTime? _equipmentMaintenanceDueDate(Equipment equipment) {
    final interval = equipment.maintenanceIntervalDays;
    final lastServiced = equipment.lastServiced;
    if (interval == null || lastServiced == null) return null;
    return lastServiced.add(Duration(days: interval));
  }

  static String _healthStatusLabel(HealthStatus status) {
    return switch (status) {
      HealthStatus.healthy => 'healthy',
      HealthStatus.sick => 'sick',
      HealthStatus.quarantine => 'in quarantine',
    };
  }
}
