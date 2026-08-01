import 'package:danio/services/browser_preview_demo.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrowserPreviewDemo', () {
    test('requires both the web platform and an explicit preview request', () {
      expect(
        isBrowserPreviewDemoEnabled(
          runningOnWeb: true,
          explicitlyRequested: true,
        ),
        isTrue,
      );
      expect(
        isBrowserPreviewDemoEnabled(
          runningOnWeb: false,
          explicitlyRequested: true,
        ),
        isFalse,
      );
      expect(
        isBrowserPreviewDemoEnabled(
          runningOnWeb: true,
          explicitlyRequested: false,
        ),
        isFalse,
      );
    });

    test(
      'creates an isolated local tank with manual temperature history',
      () async {
        final storage = await createBrowserPreviewDemoStorage();

        final tanks = await storage.getAllTanks();
        expect(tanks, hasLength(1));
        final tank = tanks.single;
        expect(tank.id, browserPreviewDemoTankId);
        expect(tank.isDemoTank, isTrue);
        expect(tank.name, contains('Preview'));
        expect(tank.notes, contains('Preview-only'));

        final logs = await storage.getLogsForTank(tank.id);
        expect(logs.where((log) => log.waterTest != null), hasLength(7));
        expect(
          (await storage.getLatestWaterTest(tank.id))?.waterTest?.temperature,
          25.0,
        );
        expect(await storage.getEquipmentForTank(tank.id), isEmpty);
      },
    );

    test('creates fresh ephemeral data for every preview launch', () async {
      final firstLaunch = await createBrowserPreviewDemoStorage();
      await firstLaunch.deleteTank(browserPreviewDemoTankId);

      final secondLaunch = await createBrowserPreviewDemoStorage();
      expect(await secondLaunch.getTank(browserPreviewDemoTankId), isNotNull);
    });

    testWidgets('opens the real Temperature panel with a preview-only marker', (
      tester,
    ) async {
      final storage = await createBrowserPreviewDemoStorage();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [storageServiceProvider.overrideWithValue(storage)],
          child: const BrowserPreviewDemoApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 1500));

      expect(
        find.byKey(const ValueKey('browser-preview-demo-banner')),
        findsOneWidget,
      );
      expect(find.text('Temperature'), findsOneWidget);
    });
  });
}
