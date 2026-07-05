import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('Tank Detail overflow keeps tank-specific actions only', () {
    final source = _source('lib/screens/tank_detail/tank_detail_screen.dart');

    expect(source, isNot(contains('CostTrackerScreen')));
    expect(source, isNot(contains("value: 'costs'")));
    expect(source, contains('Compare Tanks'));
    expect(source, contains('Estimate Value'));
    expect(source, contains('Tank Settings'));
    expect(source, contains('Delete Tank'));
  });

  test('Tank Toolbox keeps contextual tank actions only', () {
    final source = _source('lib/screens/home/home_sheets_tank.dart');

    expect(source, contains('RemindersScreen'));
    expect(source, contains('JournalScreen'));
    expect(source, isNot(contains('AnalyticsScreen')));
    expect(source, isNot(contains('SearchScreen')));
    expect(source, isNot(contains('Species Search')));
  });

  test(
    'Tank bottom sheet routes tools through Workshop instead of calculators',
    () {
      final source = _source('lib/widgets/stage/bottom_sheet_panel.dart');

      expect(source, contains('WorkshopScreen'));
      expect(source, contains('Open Workshop'));
      expect(source, isNot(contains('WaterChangeCalculatorScreen')));
      expect(source, isNot(contains('StockingCalculatorScreen')));
      expect(source, isNot(contains('CompatibilityCheckerScreen')));
      expect(source, isNot(contains('Co2CalculatorScreen')));
      expect(source, isNot(contains('See All Tools')));
    },
  );

  test('Preferences does not duplicate the More backup hub', () {
    final source = _source('lib/screens/settings/settings_screen.dart');
    final dataSectionSource = _source(
      'lib/screens/settings/settings_data_section.dart',
    );
    final notificationsSource = _source(
      'lib/screens/settings/settings_notifications_section.dart',
    );

    expect(source, isNot(contains('BackupRestoreScreen')));
    expect(source, isNot(contains('Backup & Restore')));
    expect(dataSectionSource, isNot(contains('Export All Data')));
    expect(dataSectionSource, isNot(contains('Import Data')));
    expect(dataSectionSource, isNot(contains('FilePicker.platform.pickFiles')));
    expect(dataSectionSource, isNot(contains('writeAsString(contents)')));
    expect(notificationsSource, contains('Phone Notifications'));
    expect(source, contains('OpenAI API key'));
    expect(source, contains('Light/Dark Mode'));
    expect(source, contains('Clear All Data'));
    expect(source, contains('Delete My Data'));
  });

  test('Smart labels AI advice separately from the local Workshop checker', () {
    final smartSource = _source('lib/screens/smart_screen.dart');
    final aiWidgetSource = _source(
      'lib/widgets/compatibility_checker_widget.dart',
    );

    expect(aiWidgetSource, contains('AI Compatibility Advice'));
    expect(smartSource, contains('Workshop Compatibility Checker'));
    expect(smartSource, isNot(contains("title: 'Compatibility Advice'")));
  });

  test('Main shell does not mount debug sync diagnostics', () {
    final source = _source('lib/screens/tab_navigator.dart');
    const syncIndicatorClass =
        'Sync'
        'Indicator';
    const syncIndicatorImport =
        'sync_'
        'indicator.dart';

    expect(source, contains('OfflineIndicator'));
    expect(source, isNot(contains(syncIndicatorClass)));
    expect(source, isNot(contains(syncIndicatorImport)));
  });

  test('legacy sync status scaffolds are not shipped as UI entry points', () {
    const legacyWidget =
        'lib/widgets/sync_'
        'indicator.dart';
    const legacyStatusWidget =
        'lib/widgets/sync_'
        'status_widget.dart';
    const legacyDebugDialog =
        'lib/widgets/sync_'
        'debug_dialog.dart';
    const legacyCloudSyncService =
        'lib/services/cloud_'
        'sync_service.dart';
    const hiddenStatusComment =
        'Sync status'
        ' hidden';
    const scaffoldingComment =
        'SyncService is'
        ' scaffolding';

    expect(File(legacyWidget).existsSync(), isFalse);
    expect(File(legacyStatusWidget).existsSync(), isFalse);
    expect(File(legacyDebugDialog).existsSync(), isFalse);
    expect(File(legacyCloudSyncService).existsSync(), isFalse);

    final accountSource = _source('lib/screens/account_screen.dart');
    expect(accountSource, isNot(contains(hiddenStatusComment)));
    expect(accountSource, isNot(contains(scaffoldingComment)));
  });
}
