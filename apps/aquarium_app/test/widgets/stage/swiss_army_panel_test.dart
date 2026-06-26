import 'package:danio/theme/room_themes.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/danio_bottom_dock.dart';
import 'package:danio/widgets/stage/bottom_sheet_panel.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TrackingSheetHintPrefs implements SharedPreferences {
  _TrackingSheetHintPrefs(this._delegate);

  final SharedPreferences _delegate;
  bool savedSheetHint = false;

  @override
  bool? getBool(String key) {
    if (key == 'hasSeenSheetHint') return false;
    return _delegate.getBool(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    if (key == 'hasSeenSheetHint' && value) {
      savedSheetHint = true;
    }
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}

void main() {
  group('SwissArmyPanel glass frame (concept lock 2026-04-07)', () {
    testWidgets('uses sigma:14 blur when open', (tester) async {
      // Compile-time lock for the sigma constant
      expect(SwissArmyPanel.kGlassBlurSigma, 14.0);

      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(key: Key('panel-body')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BackdropFilter is present (structural check)
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byKey(const Key('panel-body')), findsOneWidget);
    });

    testWidgets('has a drop shadow on the outer frame', (tester) async {
      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frame = tester.widget<DecoratedBox>(
        find.byKey(const Key('swiss-frame-shadow')),
      );
      final deco = frame.decoration as BoxDecoration;
      expect(deco.boxShadow, isNotNull);
      expect(deco.boxShadow!.length, 1);
      expect(deco.boxShadow!.first.color, const Color(0x40000000));
      expect(deco.boxShadow!.first.blurRadius, 8);
      expect(deco.boxShadow!.first.offset, const Offset(0, 2));
    });

    test('uses conservative viewport constants for side panels', () {
      expect(SwissArmyPanel.kPanelWidthFactor, lessThanOrEqualTo(0.68));
      expect(SwissArmyPanel.kBottomContentGutter, lessThanOrEqualTo(24));
    });

    testWidgets('hides edge handles while a side panel is open', (
      tester,
    ) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: StageHandleStrip(
              panel: StagePanel.waterQuality,
              isLeft: false,
              icon: Icons.science_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);

      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });
  });

  group('BottomSheetPanel snap contract', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasSeenSheetHint': true});
    });

    test('supports closed, peek, half, and full snap states', () {
      expect(BottomSheetPanel.kSnapClosed, closeTo(0.055, 0.005));
      expect(
        BottomSheetPanel.kSnapPeek,
        greaterThan(BottomSheetPanel.kSnapClosed),
      );
      expect(
        BottomSheetPanel.kSnapHalf,
        greaterThan(BottomSheetPanel.kSnapPeek),
      );
      expect(
        BottomSheetPanel.kSnapFull,
        greaterThan(BottomSheetPanel.kSnapHalf),
      );
      expect(BottomSheetPanel.kSnapSizes, <double>[
        BottomSheetPanel.kSnapClosed,
        BottomSheetPanel.kSnapPeek,
        BottomSheetPanel.kSnapHalf,
        BottomSheetPanel.kSnapFull,
      ]);
    });

    testWidgets('starts closed with only the handle area exposed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  BottomSheetPanel(
                    progressContent: SizedBox(),
                    tanksContent: SizedBox(),
                    todayContent: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final sheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet),
      );
      expect(sheet.initialChildSize, BottomSheetPanel.kSnapClosed);
      expect(sheet.minChildSize, BottomSheetPanel.kSnapClosed);
      expect(sheet.snapSizes, BottomSheetPanel.kSnapSizes);
    });

    testWidgets('constrains Tank sheet shell to dock straight width', (
      tester,
    ) async {
      const screenWidth = 430.0;
      final expectedWidth = DanioBottomDock.straightSheetWidthFor(screenWidth);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(screenWidth, 932)),
              child: Scaffold(
                body: Stack(
                  children: [
                    BottomSheetPanel(
                      sheetWidth: expectedWidth,
                      closedNibWidth: DanioBottomDock.stageSheetNibWidthFor(
                        screenWidth,
                      ),
                      progressContent: const SizedBox(),
                      tanksContent: const SizedBox(),
                      todayContent: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final shell = find.byKey(const ValueKey('danio-stage-sheet-shell'));
      expect(shell, findsOneWidget);
      expect(tester.getSize(shell).width, closeTo(expectedWidth, 0.1));
    });

    testWidgets('closed Tank sheet exposes compact nib without tab row', (
      tester,
    ) async {
      const screenWidth = 430.0;
      final nibWidth = DanioBottomDock.stageSheetNibWidthFor(screenWidth);
      expect(nibWidth, closeTo(176, 0.1));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(screenWidth, 932)),
              child: Scaffold(
                body: Stack(
                  children: [
                    BottomSheetPanel(
                      sheetWidth: DanioBottomDock.straightSheetWidthFor(
                        screenWidth,
                      ),
                      closedNibWidth: nibWidth,
                      closedNibHeight: DanioBottomDock.stageSheetNibHeight,
                      progressContent: const SizedBox(),
                      tanksContent: const SizedBox(),
                      todayContent: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final nib = find.byKey(const ValueKey('danio-stage-sheet-nib'));
      expect(nib, findsOneWidget);
      expect(tester.getSize(nib).width, closeTo(nibWidth, 0.1));
      expect(
        tester.getSize(nib).height,
        closeTo(DanioBottomDock.stageSheetNibHeight, 0.1),
      );
      final hitTarget = find.byKey(
        const ValueKey('danio-stage-sheet-nib-hit-target'),
      );
      final grip = find.byKey(const ValueKey('danio-stage-sheet-nib-grip'));
      expect(hitTarget, findsOneWidget);
      expect(grip, findsOneWidget);
      expect(
        tester.getTopLeft(nib).dy,
        closeTo(tester.getTopLeft(hitTarget).dy, 0.1),
      );
      expect(
        tester.getTopLeft(grip).dy,
        lessThanOrEqualTo(tester.getTopLeft(hitTarget).dy + 12),
      );
      expect(
        find.byKey(const ValueKey('danio-stage-sheet-tab-row')),
        findsNothing,
      );
    });

    testWidgets('open Tank sheet tab labels use glass colour tokens', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  BottomSheetPanel(
                    progressContent: SizedBox(),
                    tanksContent: SizedBox(),
                    todayContent: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byKey(const ValueKey('danio-stage-sheet-nib-hit-target')),
        const Offset(0, -500),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      final tabBar = tester.widget<TabBar>(
        find.byKey(const ValueKey('danio-stage-sheet-tab-row')),
      );
      expect(tabBar.labelColor, AppColors.whiteAlpha95);
      expect(tabBar.unselectedLabelColor, AppColors.whiteAlpha70);
    });

    testWidgets('open Tank sheet tab labels scale within dock width', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  BottomSheetPanel(
                    sheetWidth: 822,
                    progressContent: SizedBox(),
                    tanksContent: SizedBox(),
                    todayContent: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byKey(const ValueKey('danio-stage-sheet-nib-hit-target')),
        const Offset(0, -500),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      final tabBar = tester.widget<TabBar>(
        find.byKey(const ValueKey('danio-stage-sheet-tab-row')),
      );

      for (final tab in tabBar.tabs.cast<Tab>()) {
        expect(tab.child, isA<FittedBox>());
      }
    });

    testWidgets('persists first-use hint through shared preferences provider', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'hasSeenSheetHint': true});
      final delegate = await SharedPreferences.getInstance();
      final trackingPrefs = _TrackingSheetHintPrefs(delegate);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => trackingPrefs,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  BottomSheetPanel(
                    progressContent: SizedBox(),
                    tanksContent: SizedBox(),
                    todayContent: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(trackingPrefs.savedSheetHint, isTrue);
    });
  });
}
