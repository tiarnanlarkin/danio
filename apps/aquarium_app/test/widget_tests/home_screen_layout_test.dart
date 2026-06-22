import 'package:danio/models/models.dart';
import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/screens/home/home_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _phone = Size(390, 844);
const _tabletPortrait = Size(1200, 2000);
const _tabletLandscape = Size(2000, 1200);

Widget _wrapWithTank({
  Tank? tank,
  InMemoryStorageService? storage,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final memStorage = storage ?? InMemoryStorageService();
  final now = DateTime(2026, 1, 1);
  final resolvedTank =
      tank ??
      Tank(
        id: 'tank-layout-1',
        name: 'Layout Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
      );

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => [resolvedTank]),
      currentRoomThemeProvider.overrideWith((ref) => RoomTheme.ocean),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: const HomeScreen(),
      ),
    ),
  );
}

Future<List<FlutterErrorDetails>> _pumpCapturingFlutterErrors(
  WidgetTester tester, {
  required Size viewport,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.binding.setSurfaceSize(viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final capturedErrors = <FlutterErrorDetails>[];
  final originalOnError = FlutterError.onError;
  FlutterError.onError = capturedErrors.add;
  try {
    await tester.pumpWidget(_wrapWithTank(textScaler: textScaler));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
  } finally {
    FlutterError.onError = originalOnError;
  }

  return capturedErrors;
}

void _expectNoLayoutOverflow(List<FlutterErrorDetails> errors) {
  final overflowErrors = errors
      .where((details) => details.exceptionAsString().contains('overflowed'))
      .map((details) => details.exceptionAsString())
      .toList();

  expect(overflowErrors, isEmpty);
}

void _expectVisibleTapTarget(
  WidgetTester tester,
  Finder finder, {
  required Size viewport,
}) {
  expect(finder, findsOneWidget);

  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
  expect(rect.bottom, lessThanOrEqualTo(viewport.height));
  expect(rect.width, greaterThanOrEqualTo(48));
  expect(rect.height, greaterThanOrEqualTo(48));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'hasSeenSheetHint': true});
    NavigationThrottle.reset();
  });

  group('HomeScreen Tank layout', () {
    for (final viewport in [_phone, _tabletPortrait, _tabletLandscape]) {
      testWidgets(
        'has no layout overflow at ${viewport.width}x${viewport.height}',
        (
          tester,
        ) async {
          final errors = await _pumpCapturingFlutterErrors(
            tester,
            viewport: viewport,
          );

          _expectNoLayoutOverflow(errors);
        },
      );

      testWidgets(
        'keeps primary controls visible at ${viewport.width}x${viewport.height}',
        (tester) async {
          final errors = await _pumpCapturingFlutterErrors(
            tester,
            viewport: viewport,
          );
          _expectNoLayoutOverflow(errors);

          _expectVisibleTapTarget(
            tester,
            find.byTooltip('Emergency Guide'),
            viewport: viewport,
          );
          _expectVisibleTapTarget(
            tester,
            find.byTooltip('Search'),
            viewport: viewport,
          );
          _expectVisibleTapTarget(
            tester,
            find.bySemanticsLabel('Tank Toolbox'),
            viewport: viewport,
          );
          _expectVisibleTapTarget(
            tester,
            find.bySemanticsLabel('Open action menu'),
            viewport: viewport,
          );
          expect(
            find.bySemanticsLabel(RegExp('Activity panel')),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets('keeps primary controls stable with larger text', (
      tester,
    ) async {
      final errors = await _pumpCapturingFlutterErrors(
        tester,
        viewport: _phone,
        textScaler: const TextScaler.linear(1.3),
      );

      _expectNoLayoutOverflow(errors);
      _expectVisibleTapTarget(
        tester,
        find.byTooltip('Emergency Guide'),
        viewport: _phone,
      );
      _expectVisibleTapTarget(
        tester,
        find.byTooltip('Search'),
        viewport: _phone,
      );
      _expectVisibleTapTarget(
        tester,
        find.bySemanticsLabel('Tank Toolbox'),
        viewport: _phone,
      );
      _expectVisibleTapTarget(
        tester,
        find.bySemanticsLabel('Open action menu'),
        viewport: _phone,
      );
    });
  });
}
