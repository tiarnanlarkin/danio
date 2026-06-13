import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'water change logging does not schedule phone reminders automatically',
    () {
      final source = File(
        'lib/screens/add_log/add_log_screen.dart',
      ).readAsStringSync();

      expect(
        source,
        isNot(contains("import '../../services/notification_service.dart'")),
      );
      expect(source, isNot(contains('scheduleWaterChangeReminder')));
      expect(source, isNot(contains('NotificationService()')));
    },
  );

  test(
    'quick water test gives explicit feedback for empty and saved states',
    () {
      final source = File(
        'lib/screens/home/home_sheets_tank.dart',
      ).readAsStringSync();

      expect(source, contains('Enter at least one test value.'));
      expect(source, contains('Water test logged! +10 XP'));
      expect(source, contains('Couldn\\\'t save that water test. Try again.'));
      expect(source, contains('viewPadding.bottom'));
      expect(source, contains('DanioBottomDock.contentClearance'));
      expect(
        source,
        contains('FocusManager.instance.primaryFocus?.unfocus();'),
      );
      expect(source, contains('Future<void>.delayed(AppDurations.medium4)'));
      expect(source, contains('class _QuickWaterTestSheet'));
      expect(source, contains('extends ConsumerStatefulWidget'));
      expect(source, contains('_phC.dispose();'));
      expect(source, isNot(contains('.whenComplete(()')));
    },
  );

  test('room action menu has a non-zero hit-test surface', () {
    final source = File('lib/widgets/speed_dial_fab.dart').readAsStringSync();

    expect(source, contains('width: 360'));
    expect(source, contains('height: 560'));
    expect(source, contains("label = icon == Icons.add ? 'Open action menu'"));
    expect(source, isNot(contains('const SizedBox.shrink()')));
  });

  test('main Tank Feed action is a direct care log with safety copy', () {
    final source = File('lib/screens/home/home_screen.dart').readAsStringSync();

    expect(source, contains('Future<void> _quickLogFeeding'));
    expect(source, contains('type: LogType.feeding'));
    expect(source, contains("title: 'Fed fish'"));
    expect(source, contains('Feeding logged. Keep portions tiny.'));
    expect(source, contains('feedings today - keep portions tiny.'));
    expect(
      source,
      contains('_quickLogFeeding(context, ref, currentTank, currentLogs)'),
    );
  });

  test('Tank top bar keeps Emergency Guide directly reachable', () {
    final source = File('lib/screens/home/home_screen.dart').readAsStringSync();

    expect(source, contains("tooltip: 'Emergency Guide'"));
    expect(source, contains('const EmergencyGuideScreen()'));
    expect(source, contains('Icons.emergency_outlined'));
  });
}
