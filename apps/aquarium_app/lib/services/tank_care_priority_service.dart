import '../models/log_entry.dart';
import '../models/task.dart';

enum TankCarePriorityLevel { emergency, due, suggested, clear }

enum TankCarePriorityAction {
  emergencyGuide,
  waterChange,
  waterTest,
  feeding,
  tasks,
  none,
}

class TankCarePriority {
  final TankCarePriorityLevel level;
  final TankCarePriorityAction action;
  final String title;
  final String subtitle;
  final String semanticsLabel;

  const TankCarePriority({
    required this.level,
    required this.action,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
  });
}

class TankCarePriorityService {
  static const double unsafeNitrogenThreshold = 0.25;
  static const int staleWaterTestDays = 7;

  const TankCarePriorityService._();

  static TankCarePriority evaluate({
    required List<Task> tasks,
    required List<LogEntry> logs,
  }) {
    final latestWaterTest = _latestWaterTest(logs);
    if (_hasUnsafeNitrogen(latestWaterTest?.waterTest)) {
      return const TankCarePriority(
        level: TankCarePriorityLevel.emergency,
        action: TankCarePriorityAction.emergencyGuide,
        title: 'Unsafe water detected',
        subtitle: 'Open emergency steps, then log the water change.',
        semanticsLabel: 'Unsafe water detected. Open emergency steps.',
      );
    }

    if (tasks.any((task) => task.isEnabled && task.isOverdue)) {
      return const TankCarePriority(
        level: TankCarePriorityLevel.due,
        action: TankCarePriorityAction.tasks,
        title: 'Overdue care task',
        subtitle: 'Open tasks and clear the most important maintenance item.',
        semanticsLabel: 'Overdue care task. Open tasks.',
      );
    }

    if (latestWaterTest == null || _isStale(latestWaterTest.timestamp)) {
      return const TankCarePriority(
        level: TankCarePriorityLevel.suggested,
        action: TankCarePriorityAction.waterTest,
        title: 'Log a water test',
        subtitle: 'Fresh parameters keep Danio guidance accurate.',
        semanticsLabel: 'Log a water test.',
      );
    }

    if (!_hasFeedingToday(logs)) {
      return const TankCarePriority(
        level: TankCarePriorityLevel.suggested,
        action: TankCarePriorityAction.feeding,
        title: 'Log feeding when you feed',
        subtitle: 'Keep the routine visible without overfeeding.',
        semanticsLabel: 'Log feeding when you feed.',
      );
    }

    return const TankCarePriority(
      level: TankCarePriorityLevel.clear,
      action: TankCarePriorityAction.none,
      title: 'Care on track',
      subtitle: 'No urgent care actions found right now.',
      semanticsLabel: 'Care on track.',
    );
  }

  static LogEntry? _latestWaterTest(List<LogEntry> logs) {
    final waterTests =
        logs
            .where(
              (log) => log.type == LogType.waterTest && log.waterTest != null,
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return waterTests.isEmpty ? null : waterTests.first;
  }

  static bool _hasUnsafeNitrogen(WaterTestResults? results) {
    if (results == null) return false;
    return (results.ammonia ?? 0) > unsafeNitrogenThreshold ||
        (results.nitrite ?? 0) > unsafeNitrogenThreshold;
  }

  static bool _isStale(DateTime timestamp) {
    return DateTime.now().difference(timestamp).inDays > staleWaterTestDays;
  }

  static bool _hasFeedingToday(List<LogEntry> logs) {
    final now = DateTime.now();
    return logs.any(
      (log) =>
          log.type == LogType.feeding &&
          log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day,
    );
  }
}
