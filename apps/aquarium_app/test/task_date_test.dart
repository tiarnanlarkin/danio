import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/task.dart';

void main() {
  group('P0-3: Monthly Task Recurrence - Date Clamping', () {
    late Task monthlyTask;

    setUp(() {
      monthlyTask = Task(
        id: 'test-monthly',
        title: 'Monthly Test Task',
        recurrence: RecurrenceType.monthly,
        dueDate: DateTime(2024, 1, 31), // Jan 31
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('Jan 31 → Feb should clamp to Feb 28 (non-leap year)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2023, 1, 31));
      final completed = task.complete();
      
      expect(completed.dueDate, isNotNull);
      expect(completed.dueDate!.year, 2023);
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 28); // Non-leap year
    });

    test('Jan 31 → Feb should clamp to Feb 29 (leap year)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 1, 31));
      final completed = task.complete();
      
      expect(completed.dueDate, isNotNull);
      expect(completed.dueDate!.year, 2024);
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 29); // Leap year
    });

    test('Jan 29 → Feb should clamp to Feb 29 (leap year)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 1, 29));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 29);
    });

    test('Jan 30 → Feb should clamp to Feb 28 (non-leap year)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2023, 1, 30));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 28);
    });

    test('Mar 31 → Apr should clamp to Apr 30', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 3, 31));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 4);
      expect(completed.dueDate!.day, 30);
    });

    test('May 31 → Jun should clamp to Jun 30', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 5, 31));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 6);
      expect(completed.dueDate!.day, 30);
    });

    test('Aug 31 → Sep should clamp to Sep 30', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 8, 31));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 9);
      expect(completed.dueDate!.day, 30);
    });

    test('Oct 31 → Nov should clamp to Nov 30', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 10, 31));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 11);
      expect(completed.dueDate!.day, 30);
    });

    test('Dec 31 → Jan (next year) should keep day 31', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 12, 31));
      final completed = task.complete();
      
      expect(completed.dueDate!.year, 2025);
      expect(completed.dueDate!.month, 1);
      expect(completed.dueDate!.day, 31);
    });

    test('Jan 31 → Feb 28 → Mar should clamp to Mar 28', () {
      // Test that the clamped day persists through subsequent months
      final jan31 = monthlyTask.copyWith(dueDate: DateTime(2023, 1, 31));
      final feb28 = jan31.complete(); // Should be Feb 28
      
      expect(feb28.dueDate!.day, 28);
      
      final mar = feb28.complete(); // Should be Mar 28 (not Mar 31)
      expect(mar.dueDate!.month, 3);
      expect(mar.dueDate!.day, 28);
    });

    test('Should handle normal dates (day ≤ 28) without clamping', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 1, 15));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 15); // No clamping needed
    });

    test('Leap year detection: 2024 is leap year', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 1, 29));
      final completed = task.complete();
      
      expect(completed.dueDate!.day, 29); // Feb 29 exists in 2024
    });

    test('Leap year detection: 2100 is NOT leap year (century rule)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2100, 1, 29));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 28); // 2100 is not a leap year
    });

    test('Leap year detection: 2000 IS leap year (400-year rule)', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2000, 1, 29));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 2);
      expect(completed.dueDate!.day, 29); // 2000 is a leap year
    });

    test('Edge case: Feb 29 (leap year) → Mar should keep day 29', () {
      final task = monthlyTask.copyWith(dueDate: DateTime(2024, 2, 29));
      final completed = task.complete();
      
      expect(completed.dueDate!.month, 3);
      expect(completed.dueDate!.day, 29); // March has 31 days
    });

    test('Stress test: All months in sequence', () {
      // Start Jan 31, complete 12 times, verify no crashes
      var task = monthlyTask.copyWith(dueDate: DateTime(2024, 1, 31));
      
      final expectedDays = [
        29, // Jan 31 → Feb 29 (2024 is leap year)
        29, // Feb 29 → Mar 29
        29, // Mar 29 → Apr 29
        29, // Apr 29 → May 29
        29, // May 29 → Jun 29
        29, // Jun 29 → Jul 29
        29, // Jul 29 → Aug 29
        29, // Aug 29 → Sep 29
        29, // Sep 29 → Oct 29
        29, // Oct 29 → Nov 29
        29, // Nov 29 → Dec 29
        29, // Dec 29 → Jan 29 (2025)
      ];

      for (var i = 0; i < 12; i++) {
        task = task.complete();
        expect(task.dueDate, isNotNull, reason: 'Month $i should not crash');
        expect(task.dueDate!.day, expectedDays[i], 
               reason: 'Month ${i + 2} should have day ${expectedDays[i]}');
      }
    });
  });

  group('Other Recurrence Types', () {
    test('Daily recurrence adds 1 day', () {
      final task = Task(
        id: 'daily',
        title: 'Daily Task',
        recurrence: RecurrenceType.daily,
        dueDate: DateTime(2024, 2, 28),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completed = task.complete();
      expect(completed.dueDate!.difference(task.dueDate!).inDays, 1);
    });

    test('Weekly recurrence adds 7 days', () {
      final task = Task(
        id: 'weekly',
        title: 'Weekly Task',
        recurrence: RecurrenceType.weekly,
        dueDate: DateTime(2024, 2, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completed = task.complete();
      expect(completed.dueDate!.difference(task.dueDate!).inDays, 7);
    });

    test('Biweekly recurrence adds 14 days', () {
      final task = Task(
        id: 'biweekly',
        title: 'Biweekly Task',
        recurrence: RecurrenceType.biweekly,
        dueDate: DateTime(2024, 2, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completed = task.complete();
      expect(completed.dueDate!.difference(task.dueDate!).inDays, 14);
    });

    test('Custom recurrence adds specified days', () {
      final task = Task(
        id: 'custom',
        title: 'Custom Task',
        recurrence: RecurrenceType.custom,
        intervalDays: 10,
        dueDate: DateTime(2024, 2, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completed = task.complete();
      expect(completed.dueDate!.difference(task.dueDate!).inDays, 10);
    });

    test('None recurrence returns null', () {
      final task = Task(
        id: 'none',
        title: 'One-time Task',
        recurrence: RecurrenceType.none,
        dueDate: DateTime(2024, 2, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completed = task.complete();
      expect(completed.dueDate, isNull);
    });
  });
}
