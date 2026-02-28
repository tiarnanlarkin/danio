import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/screens/tank_detail/tank_detail_screen.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/quick_stats.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/alerts_card.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/equipment_preview.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/livestock_preview.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/logs_list.dart';
import 'package:aquarium_app/screens/tank_detail/widgets/quick_add_fab.dart';
import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/providers/tank_provider.dart';
import 'package:aquarium_app/theme/app_theme.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('TankDetailScreen', () {
    late Tank mockTank;
    late List<LogEntry> mockLogs;
    late List<Livestock> mockLivestock;
    late List<Equipment> mockEquipment;
    late List<Task> mockTasks;

    setUp(() {
      mockTank = MockData.mockTank(
        id: 'test-tank-1',
        name: 'Community Tank',
        volumeLitres: 200.0,
      );

      mockLogs = [
        MockData.mockLog(
          id: 'log-1',
          tankId: 'test-tank-1',
          type: LogType.waterTest,
          waterTest: MockData.mockWaterTest(
            ph: 7.2,
            ammonia: 0.0,
            nitrite: 0.0,
            nitrate: 15.0,
            temperature: 25.5,
          ),
        ),
        MockData.mockLog(
          id: 'log-2',
          tankId: 'test-tank-1',
          type: LogType.waterChange,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      mockLivestock = [];
      mockEquipment = [];
      mockTasks = [];
    });

    testWidgets('renders without crashing', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(TankDetailScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows tank name in app bar', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Community Tank'), findsOneWidget);
    });

    testWidgets('displays quick stats section', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // QuickStats widget should display water parameters
      final quickStatsWidget = find.byType(QuickStats);
      expect(quickStatsWidget, findsOneWidget);
    });

    testWidgets('shows action buttons for logging', skip: true, (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Should find action buttons
      expect(find.text('Log Test'), findsWidgets);
      expect(find.text('Water Change'), findsWidgets);
      expect(find.text('Add Note'), findsWidgets);
    });

    testWidgets('displays alerts when present', skip: true, (tester) async {
      // Create logs with out-of-range parameters to trigger alerts
      final alertLogs = [
        MockData.mockLog(
          id: 'alert-log',
          tankId: 'test-tank-1',
          type: LogType.waterTest,
          waterTest: MockData.mockWaterTest(
            ph: 8.5, // High pH should trigger alert
            ammonia: 0.5, // High ammonia should trigger alert
            nitrite: 0.0,
            nitrate: 15.0,
          ),
        ),
      ];

      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => alertLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => alertLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // AlertsCard should be present
      expect(find.byType(AlertsCard), findsAny);
    });

    testWidgets('shows empty state when no alerts', skip: true, (tester) async {
      // Normal parameters, no alerts
      final normalLogs = [
        MockData.mockLog(
          id: 'normal-log',
          tankId: 'test-tank-1',
          type: LogType.waterTest,
          waterTest: MockData.mockWaterTest(
            ph: 7.0,
            ammonia: 0.0,
            nitrite: 0.0,
            nitrate: 10.0,
          ),
        ),
      ];

      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => normalLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => normalLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // AlertsCard should still render but show no alerts
      expect(find.byType(AlertsCard), findsAny);
    });

    testWidgets('equipment preview displays', skip: true, (tester) async {
      final equipment = [
        Equipment(
          id: 'eq-1',
          tankId: 'test-tank-1',
          name: 'Fluval 307',
          type: EquipmentType.filter,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => equipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Equipment section should be present
      expect(find.text('Equipment'), findsWidgets);
      expect(find.byType(EquipmentPreview), findsOneWidget);
    });

    testWidgets('livestock preview displays', skip: true, (tester) async {
      final livestock = [
        Livestock(
          id: 'live-1',
          tankId: 'test-tank-1',
          commonName: 'Neon Tetra',
          count: 10,
          dateAdded: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => livestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Livestock section should be present
      expect(find.text('Livestock'), findsWidgets);
      expect(find.byType(LivestockPreview), findsOneWidget);
      expect(find.text('10 fish'), findsWidgets);
    });

    testWidgets('logs list renders recent activity', skip: true, (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Recent Activity section should be present
      expect(find.text('Recent Activity'), findsWidgets);
      expect(find.byType(LogsList), findsOneWidget);
    });

    testWidgets('has floating action button for quick add', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Should have QuickAddFab
      expect(find.byType(QuickAddFab), findsOneWidget);
    });

    testWidgets('shows loading state while fetching tank', skip: true, (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return mockTank;
          }),
        ],
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsAny);

      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('handles error state when tank not found', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'non-existent'),
        overrides: [
          tankProvider('non-existent').overrideWith((ref) async => null),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Not Found'), findsOneWidget);
      expect(find.text('Tank not found'), findsOneWidget);
    });

    testWidgets('handles error state on load failure', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'error-tank'),
        overrides: [
          tankProvider('error-tank').overrideWith((ref) async {
            throw Exception('Database error');
          }),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Failed to load tank'), findsOneWidget);
    });

    testWidgets('tasks section shows pending tasks count', skip: true, (tester) async {
      final tasks = [
        Task(
          id: 'task-1',
          tankId: 'test-tank-1',
          title: 'Clean filter',
          isEnabled: true,
          recurrence: RecurrenceType.weekly,
          dueDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue
          intervalDays: 7,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: 'task-2',
          tankId: 'test-tank-1',
          title: 'Test water',
          isEnabled: true,
          recurrence: RecurrenceType.weekly,
          dueDate: DateTime.now(), // Due today
          intervalDays: 7,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => tasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Should show task count badge
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
    });

    testWidgets('menu has all expected options', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Find and tap the menu button
      final menuButton = find.byIcon(Icons.more_vert);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Check menu items
      expect(find.text('Compare Tanks'), findsOneWidget);
      expect(find.text('Cost Tracker'), findsOneWidget);
      expect(find.text('Estimate Value'), findsOneWidget);
      expect(find.text('Tank Settings'), findsOneWidget);
      expect(find.text('Delete Tank'), findsOneWidget);
    });

    testWidgets('toolbar icons are present', (tester) async {
      await pumpWithProviders(
        tester,
        const TankDetailScreen(tankId: 'test-tank-1'),
        overrides: [
          tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
          logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
          livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
          equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
          tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
        ],
      );
      // Resolve async providers via runAsync then pump to rebuild
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(Duration.zero));
      await tester.pump();
      // Advance animation timers
      await tester.pump(const Duration(seconds: 1));

      // Check toolbar icons
      expect(find.byIcon(Icons.checklist), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });
  });
}
