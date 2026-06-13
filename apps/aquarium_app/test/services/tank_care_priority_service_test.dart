import 'package:danio/models/log_entry.dart';
import 'package:danio/models/task.dart';
import 'package:danio/services/tank_care_priority_service.dart';
import 'package:flutter_test/flutter_test.dart';

LogEntry _waterTest({
  int daysAgo = 0,
  double? ammonia = 0.0,
  double? nitrite = 0.0,
}) {
  final timestamp = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: 'water-test-$daysAgo',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: timestamp,
    createdAt: timestamp,
    waterTest: WaterTestResults(ammonia: ammonia, nitrite: nitrite),
  );
}

LogEntry _feeding({int daysAgo = 0}) {
  final timestamp = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: 'feeding-$daysAgo',
    tankId: 'tank-1',
    type: LogType.feeding,
    timestamp: timestamp,
    createdAt: timestamp,
  );
}

Task _task({required String id, bool overdue = false, bool enabled = true}) {
  final now = DateTime.now();
  return Task(
    id: id,
    tankId: 'tank-1',
    title: 'Water Change',
    recurrence: RecurrenceType.weekly,
    dueDate: overdue
        ? now.subtract(const Duration(days: 1))
        : now.add(const Duration(days: 1)),
    priority: TaskPriority.normal,
    isEnabled: enabled,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TankCarePriorityService.evaluate', () {
    test('ammonia above 0.25 returns emergency guide priority', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: [_task(id: 'task-1', overdue: true)],
        logs: [_waterTest(ammonia: 0.5), _feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.emergency);
      expect(priority.action, TankCarePriorityAction.emergencyGuide);
      expect(priority.title, 'Unsafe water detected');
      expect(priority.subtitle, contains('emergency steps'));
    });

    test('nitrite above 0.25 returns emergency guide priority', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: const [],
        logs: [_waterTest(nitrite: 0.5), _feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.emergency);
      expect(priority.action, TankCarePriorityAction.emergencyGuide);
      expect(priority.title, 'Unsafe water detected');
      expect(priority.subtitle, contains('emergency steps'));
    });

    test('overdue enabled task returns task priority without emergency', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: [
          _task(id: 'disabled-overdue', overdue: true, enabled: false),
          _task(id: 'enabled-overdue', overdue: true),
        ],
        logs: [_waterTest(), _feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.due);
      expect(priority.action, TankCarePriorityAction.tasks);
      expect(priority.title, 'Overdue care task');
    });

    test('no water test returns water-test priority', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: const [],
        logs: [_feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.suggested);
      expect(priority.action, TankCarePriorityAction.waterTest);
      expect(priority.title, 'Log a water test');
    });

    test('stale water test returns water-test priority', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: const [],
        logs: [_waterTest(daysAgo: 8), _feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.suggested);
      expect(priority.action, TankCarePriorityAction.waterTest);
      expect(priority.title, 'Log a water test');
    });

    test('safe recent test without feeding today returns feeding priority', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: const [],
        logs: [_waterTest()],
      );

      expect(priority.level, TankCarePriorityLevel.suggested);
      expect(priority.action, TankCarePriorityAction.feeding);
      expect(priority.title, 'Log feeding when you feed');
    });

    test('safe recent test and feeding today returns clear state', () {
      final priority = TankCarePriorityService.evaluate(
        tasks: const [],
        logs: [_waterTest(), _feeding()],
      );

      expect(priority.level, TankCarePriorityLevel.clear);
      expect(priority.action, TankCarePriorityAction.none);
      expect(priority.title, 'Care on track');
    });
  });
}
