import 'dart:async';
import 'dart:math' as math;

import 'package:danio/main.dart' as app;
import 'package:danio/providers/tank_visual_event_provider.dart';
import 'package:danio/screens/learn/learn_screen.dart';
import 'package:danio/utils/performance_targets.dart';
import 'package:danio/utils/phone_performance_report.dart';
import 'package:danio/widgets/room/living_room_scene.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'phone_performance_harness.dart';

const _productCommit = String.fromEnvironment('DANIO_PRODUCT_COMMIT');
const _device = String.fromEnvironment('DANIO_PERF_DEVICE');
const _phase = String.fromEnvironment('DANIO_PERF_PHASE');
const _iteration = int.fromEnvironment(
  'DANIO_PERF_ITERATION',
  defaultValue: -1,
);

const _dockKey = ValueKey('danio-bottom-dock');
const _performanceLearnKey = ValueKey('phone-performance-learn-screen');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('records the profile-mode phone performance contract', (
    tester,
  ) async {
    _expectValidIdentity();
    await app.main();
    await _waitForFinder(tester, find.byKey(_dockKey));

    final records = switch (_phase) {
      'image' => [await _measureLocalImageFirstFrame(tester)],
      'interactions' => [
        ...await _measureTabSwitching(tester),
        ...await _measureTankFeedback(tester, binding),
        ...await _measureScrolling(tester, binding),
      ],
      _ => throw StateError(
        'DANIO_PERF_PHASE must be image or interactions.',
      ),
    };

    binding.reportData = PhonePerformanceRun(
      productCommit: _productCommit,
      device: _device,
      records: records,
    ).toJson();
  });
}

void _expectValidIdentity() {
  expect(
    kProfileMode,
    isTrue,
    reason: 'Phone performance evidence is valid only in profile mode.',
  );
  expect(
    RegExp(r'^[0-9a-f]{40}$').hasMatch(_productCommit),
    isTrue,
    reason: 'DANIO_PRODUCT_COMMIT must be a full lowercase Git commit.',
  );
  expect(
    _device,
    startsWith('danio_api36 ('),
    reason: 'DANIO_PERF_DEVICE must identify the owned phone AVD and serial.',
  );
}

Future<List<PhonePerformanceRecord>> _measureTabSwitching(
  WidgetTester tester,
) async {
  const destinations = ['learn', 'tank', 'practice', 'tank', 'more', 'tank'];
  final records = <PhonePerformanceRecord>[];
  for (var iteration = 0; iteration < destinations.length; iteration++) {
    final destination = destinations[iteration];
    final stopwatch = Stopwatch()..start();
    await tester.tap(
      find.byKey(ValueKey('danio-bottom-dock-item-$destination')),
    );
    await tester.pump();
    await _waitForFinder(
      tester,
      find.byKey(
        ValueKey('danio-bottom-dock-item-$destination-selected'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    stopwatch.stop();

    records.add(
      PhonePerformanceRecord.latency(
        scenario: DanioPerformanceScenario.tabSwitch,
        warmUp: iteration == 0,
        samplesMs: [stopwatch.elapsedMicroseconds / 1000],
      ),
    );
  }
  return records;
}

Future<PhonePerformanceRecord> _measureLocalImageFirstFrame(
  WidgetTester tester,
) async {
  expect(_iteration, inInclusiveRange(0, 5));
  final rootContext = tester.element(find.byKey(_dockKey));
  PaintingBinding.instance.imageCache
    ..clear()
    ..clearLiveImages();
  final imageFinder = find.descendant(
    of: find.byKey(_performanceLearnKey),
    matching: find.byWidgetPredicate(
      isLearnHeaderAssetImage,
      description: 'the visible local Learn header asset',
    ),
  );
  final rawImageFinder = find.descendant(
    of: imageFinder,
    matching: find.byType(RawImage),
  );

  final stopwatch = Stopwatch()..start();
  unawaited(
    Navigator.of(rootContext, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LearnScreen(key: _performanceLearnKey),
      ),
    ),
  );
  await tester.pump();
  final timeout = Stopwatch()..start();
  while (timeout.elapsed < const Duration(seconds: 5)) {
    await tester.pump(const Duration(milliseconds: 16));
    if (rawImageFinder.evaluate().isNotEmpty) {
      final renderImage = tester.renderObject<RenderImage>(
        rawImageFinder.first,
      );
      if (renderImage.image != null && !renderImage.paintBounds.isEmpty) {
        break;
      }
    }
  }
  stopwatch.stop();
  expect(rawImageFinder, findsOneWidget);
  final renderImage = tester.renderObject<RenderImage>(rawImageFinder.first);
  expect(renderImage.attached, isTrue);
  expect(renderImage.paintBounds.isEmpty, isFalse);
  expect(
    renderImage.image != null,
    isTrue,
    reason: 'The visible Learn header did not paint within five seconds.',
  );

  return PhonePerformanceRecord.latency(
    scenario: DanioPerformanceScenario.imageLoading,
    warmUp: _iteration == 0,
    samplesMs: [stopwatch.elapsedMicroseconds / 1000],
  );
}

Future<List<PhonePerformanceRecord>> _measureTankFeedback(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await _selectTab(tester, 'tank');
  final sceneFinder = find.byType(LivingRoomScene).hitTestable().first;
  await _waitForFinder(tester, sceneFinder);
  final scene = tester.widget<LivingRoomScene>(sceneFinder);
  final container = ProviderScope.containerOf(tester.element(sceneFinder));
  final pulseNotifier = container.read(
    tankFeedingPulseProvider(scene.tankId).notifier,
  );
  final records = <PhonePerformanceRecord>[];

  for (var trace = 1; trace <= 3; trace++) {
    final nextPulse = pulseNotifier.state + 1;
    records.add(
      await _watchFrameTrace(
        binding: binding,
        scenario: DanioPerformanceScenario.tankAnimation,
        traceIndex: trace,
        action: () async {
          pulseNotifier.state = nextPulse;
          for (var frame = 0; frame < 60; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      ),
    );
    expect(
      find.byKey(ValueKey('tank-feeding-animation-$nextPulse')),
      findsOneWidget,
    );
  }
  return records;
}

Future<List<PhonePerformanceRecord>> _measureScrolling(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await _selectTab(tester, 'learn');
  final scrollView = find.byType(CustomScrollView).hitTestable().first;
  await _waitForFinder(tester, scrollView);
  final records = <PhonePerformanceRecord>[];

  for (var trace = 1; trace <= 3; trace++) {
    await tester.drag(scrollView, const Offset(0, 1600));
    await tester.pump(const Duration(milliseconds: 300));
    records.add(
      await _watchFrameTrace(
        binding: binding,
        scenario: DanioPerformanceScenario.mainScrolling,
        traceIndex: trace,
        action: () async {
          await tester.fling(scrollView, const Offset(0, -700), 1400);
          for (var frame = 0; frame < 45; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      ),
    );
  }
  return records;
}

Future<PhonePerformanceRecord> _watchFrameTrace({
  required IntegrationTestWidgetsFlutterBinding binding,
  required DanioPerformanceScenario scenario,
  required int traceIndex,
  required Future<void> Function() action,
}) async {
  final reportKey = '${scenario.wireName}_trace_$traceIndex';
  await binding.watchPerformance(action, reportKey: reportKey);
  final summary = binding.reportData?[reportKey];
  if (summary is! Map<Object?, Object?>) {
    throw StateError('$reportKey produced no frame timing summary.');
  }
  final buildMicros = _numericList(summary['frame_build_times'], reportKey);
  final rasterMicros = _numericList(
    summary['frame_rasterizer_times'],
    reportKey,
  );
  if (buildMicros.length != rasterMicros.length || buildMicros.isEmpty) {
    throw StateError('$reportKey produced mismatched or empty frame timings.');
  }
  final frameTimesMs = <double>[];
  for (var index = 0; index < buildMicros.length; index++) {
    frameTimesMs.add(math.max(buildMicros[index], rasterMicros[index]) / 1000);
  }
  binding.reportData!.remove(reportKey);

  return PhonePerformanceRecord.frameTrace(
    scenario: scenario,
    traceIndex: traceIndex,
    frameTimesMs: frameTimesMs,
    buildTimesMs: buildMicros.map((value) => value / 1000).toList(),
    rasterTimesMs: rasterMicros.map((value) => value / 1000).toList(),
  );
}

List<double> _numericList(Object? value, String reportKey) {
  if (value is! List<Object?>) {
    throw StateError('$reportKey has no numeric timing list.');
  }
  return value.map((item) {
    if (item is! num) {
      throw StateError('$reportKey contains a non-numeric timing.');
    }
    return item.toDouble();
  }).toList();
}

Future<void> _selectTab(WidgetTester tester, String destination) async {
  final selected = find.byKey(
    ValueKey('danio-bottom-dock-item-$destination-selected'),
  );
  if (selected.evaluate().isEmpty) {
    await tester.tap(
      find.byKey(ValueKey('danio-bottom-dock-item-$destination')),
    );
    await tester.pump();
    await _waitForFinder(tester, selected);
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 16));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder.');
}
