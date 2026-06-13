/// Practice drill models.
///
/// Skill drills group existing review cards into real aquarium-care workflows
/// without changing the spaced repetition card model.
library;

import 'package:flutter/foundation.dart';

import 'equipment.dart';
import 'livestock.dart';
import 'log_entry.dart';
import 'task.dart';

enum PracticeDrillId {
  parameterInterpretation,
  diagnosis,
  compatibility,
  setupPlanning,
  emergencyDecision,
}

@immutable
class PracticeDrill {
  final PracticeDrillId id;
  final String title;
  final String subtitle;
  final List<String> pathIds;
  final int sessionLimit;

  const PracticeDrill({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pathIds,
    this.sessionLimit = 10,
  });
}

@immutable
class PracticeDrillSummary {
  final PracticeDrill drill;
  final int availableCardCount;
  final int dueCardCount;
  final int weakCardCount;
  final String statusLabel;
  final List<String> supportingPathTitles;
  final String? contextHint;
  final int contextPriority;

  const PracticeDrillSummary({
    required this.drill,
    required this.availableCardCount,
    required this.dueCardCount,
    required this.weakCardCount,
    required this.statusLabel,
    this.supportingPathTitles = const [],
    this.contextHint,
    this.contextPriority = 0,
  });

  bool get isUnlocked => availableCardCount > 0;
}

@immutable
class PracticeDrillContext {
  final WaterTestResults? latestWaterTest;
  final int? latestWaterTestAgeDays;
  final int overdueTaskCount;
  final int livestockCount;
  final int healthAlertCount;
  final int equipmentCount;

  const PracticeDrillContext({
    this.latestWaterTest,
    this.latestWaterTestAgeDays,
    this.overdueTaskCount = 0,
    this.livestockCount = 0,
    this.healthAlertCount = 0,
    this.equipmentCount = 0,
  });

  factory PracticeDrillContext.fromTankData({
    required List<LogEntry> logs,
    required List<Task> tasks,
    required List<Livestock> livestock,
    required List<Equipment> equipment,
    DateTime? now,
  }) {
    final referenceTime = now ?? DateTime.now();
    final latestWaterLog = _latestWaterTestLog(logs);

    return PracticeDrillContext(
      latestWaterTest: latestWaterLog?.waterTest,
      latestWaterTestAgeDays: latestWaterLog == null
          ? null
          : _wholeDaysBetween(latestWaterLog.timestamp, referenceTime),
      overdueTaskCount: tasks
          .where((task) => _isTaskOverdue(task, referenceTime))
          .length,
      livestockCount: livestock.fold<int>(0, (sum, item) => sum + item.count),
      healthAlertCount: livestock
          .where((item) => item.healthStatus != HealthStatus.healthy)
          .length,
      equipmentCount: equipment.length,
    );
  }

  bool get hasUnsafeWater {
    final test = latestWaterTest;
    if (test == null) return false;
    return (test.ammonia ?? 0) > 0 || (test.nitrite ?? 0) > 0;
  }

  bool get hasMissingOrStaleWaterTest {
    final age = latestWaterTestAgeDays;
    return latestWaterTest == null || (age != null && age > 14);
  }

  bool get hasHighNitrate => (latestWaterTest?.nitrate ?? 0) >= 40;

  static LogEntry? _latestWaterTestLog(List<LogEntry> logs) {
    LogEntry? latest;
    for (final log in logs) {
      if (log.type != LogType.waterTest || log.waterTest?.hasValues != true) {
        continue;
      }
      if (latest == null || log.timestamp.isAfter(latest.timestamp)) {
        latest = log;
      }
    }
    return latest;
  }

  static bool _isTaskOverdue(Task task, DateTime now) {
    final dueDate = task.dueDate;
    if (dueDate == null || !task.isEnabled) return false;
    return now.isAfter(dueDate);
  }

  static int _wholeDaysBetween(DateTime earlier, DateTime later) {
    final start = DateTime(earlier.year, earlier.month, earlier.day);
    final end = DateTime(later.year, later.month, later.day);
    return end.difference(start).inDays;
  }
}
