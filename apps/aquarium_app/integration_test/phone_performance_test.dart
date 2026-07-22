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
const _minimalScrollKey = ValueKey('phone-performance-minimal-scroll');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive;

  testWidgets('records the profile-mode phone performance contract', (
    tester,
  ) async {
    _expectValidIdentity();
    await app.main();
    await _waitForFinder(tester, find.byKey(_dockKey));

    final report = switch (_phase) {
      'image' => PhonePerformanceRun(
        productCommit: _productCommit,
        device: _device,
        records: [await _measureLocalImageFirstFrame(tester)],
      ).toJson(),
      'interactions' => PhonePerformanceRun(
        productCommit: _productCommit,
        device: _device,
        records: [
          ...await _measureTabSwitching(tester),
          ...await _measureTankFeedback(tester, binding),
          ...await _measureScrolling(tester, binding),
        ],
      ).toJson(),
      'attribution_image' => await _measureImageAttribution(tester),
      'attribution_interactions' => await _measureInteractionAttribution(
        tester,
        binding,
      ),
      _ => throw StateError(
        'DANIO_PERF_PHASE must select an authoritative or attribution phase.',
      ),
    };
    binding.reportData = report;
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

Future<Map<String, Object?>> _measureImageAttribution(
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

  double? mountReadyMs;
  double? decodeReadyMs;
  double? paintReadyMs;
  String? assetName;
  final timeout = Stopwatch()..start();
  while (timeout.elapsed < const Duration(seconds: 5)) {
    await tester.pump(const Duration(milliseconds: 16));
    if (imageFinder.evaluate().isNotEmpty) {
      mountReadyMs ??= stopwatch.elapsedMicroseconds / 1000;
      final image = tester.widget<Image>(imageFinder.first);
      assetName ??= unwrapPhonePerformanceAssetImage(image.image)?.assetName;
    }
    if (rawImageFinder.evaluate().isEmpty) continue;
    final renderImage = tester.renderObject<RenderImage>(rawImageFinder.first);
    if (renderImage.image != null) {
      decodeReadyMs ??= stopwatch.elapsedMicroseconds / 1000;
    }
    if (decodeReadyMs != null &&
        renderImage.attached &&
        !renderImage.paintBounds.isEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
      await WidgetsBinding.instance.endOfFrame;
      paintReadyMs = stopwatch.elapsedMicroseconds / 1000;
      break;
    }
  }
  stopwatch.stop();

  expect(mountReadyMs, isNotNull, reason: 'Learn header never mounted.');
  expect(decodeReadyMs, isNotNull, reason: 'Learn header never decoded.');
  expect(
    paintReadyMs,
    isNotNull,
    reason: 'Learn header never became paint-ready.',
  );
  expect(
    assetName,
    isNotNull,
    reason: 'Learn header asset was not identified.',
  );

  return <String, Object?>{
    'schema_version': 1,
    'diagnostic': 'paired_profile_attribution_image',
    'product_commit': _productCommit,
    'device': _device,
    'profile_mode': kProfileMode,
    'sample': <String, Object?>{
      'iteration': _iteration,
      'warm_up': _iteration == 0,
      'navigation_start_ms': 0.0,
      'mount_ready_ms': mountReadyMs!,
      'decode_ready_ms': decodeReadyMs!,
      'paint_ready_ms': paintReadyMs!,
      'asset_name': assetName!,
    },
  };
}

Future<Map<String, Object?>> _measureInteractionAttribution(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  final tankPairs = await _measureTankAttribution(tester, binding);
  final scrollingPairs = await _measureScrollingAttribution(tester, binding);
  return <String, Object?>{
    'schema_version': 1,
    'diagnostic': 'paired_profile_attribution_interactions',
    'product_commit': _productCommit,
    'device': _device,
    'profile_mode': kProfileMode,
    'tank_feedback_pairs': tankPairs,
    'scrolling_pairs': scrollingPairs,
  };
}

Future<List<Map<String, Object?>>> _measureTankAttribution(
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
  final pairs = <Map<String, Object?>>[];

  for (var pairIndex = 1; pairIndex <= 3; pairIndex++) {
    final idle = await _watchDiagnosticFrameTrace(
      binding: binding,
      reportKey: 'tank_idle_pair_$pairIndex',
      action: () => _pumpDiagnosticFrames(tester, durationPumps: 60),
    );
    final nextPulse = pulseNotifier.state + 1;
    final feeding = await _watchDiagnosticFrameTrace(
      binding: binding,
      reportKey: 'tank_feeding_pair_$pairIndex',
      action: () async {
        pulseNotifier.state = nextPulse;
        await _pumpDiagnosticFrames(tester, durationPumps: 60);
      },
    );
    expect(
      find.byKey(ValueKey('tank-feeding-animation-$nextPulse')),
      findsOneWidget,
    );
    pairs.add(<String, Object?>{
      'pair_index': pairIndex,
      'duration_pumps_per_trace': 60,
      'idle': idle,
      'feeding': feeding,
    });
  }
  return pairs;
}

Future<List<Map<String, Object?>>> _measureScrollingAttribution(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await _selectTab(tester, 'learn');
  final learnScroll = find.byType(CustomScrollView).hitTestable().first;
  await _waitForFinder(tester, learnScroll);
  final rootContext = tester.element(find.byKey(_dockKey));
  final pairs = <Map<String, Object?>>[];

  for (var pairIndex = 1; pairIndex <= 3; pairIndex++) {
    await tester.drag(learnScroll, const Offset(0, 1600));
    await tester.pump(const Duration(milliseconds: 300));
    final learn = await _watchDiagnosticFrameTrace(
      binding: binding,
      reportKey: 'learn_scroll_pair_$pairIndex',
      action: () => _performDiagnosticFling(
        tester,
        learnScroll,
        durationPumps: 45,
      ),
    );

    unawaited(
      Navigator.of(rootContext, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const _MinimalPerformanceScrollSurface(),
        ),
      ),
    );
    await _waitForFinder(tester, find.byKey(_minimalScrollKey));
    await tester.pump(const Duration(milliseconds: 400));
    final minimalScroll = find.byKey(_minimalScrollKey).hitTestable();
    await tester.drag(minimalScroll, const Offset(0, 1600));
    await tester.pump(const Duration(milliseconds: 300));
    final minimal = await _watchDiagnosticFrameTrace(
      binding: binding,
      reportKey: 'minimal_scroll_pair_$pairIndex',
      action: () => _performDiagnosticFling(
        tester,
        minimalScroll,
        durationPumps: 45,
      ),
    );
    Navigator.of(
      tester.element(find.byKey(_minimalScrollKey)),
    ).pop();
    await tester.pump(const Duration(milliseconds: 400));

    pairs.add(<String, Object?>{
      'pair_index': pairIndex,
      'duration_pumps_per_trace': 45,
      'fling_offset_dy': -700.0,
      'fling_velocity': 1400.0,
      'learn': learn,
      'minimal': minimal,
    });
  }
  return pairs;
}

Future<void> _performDiagnosticFling(
  WidgetTester tester,
  Finder scrollView, {
  required int durationPumps,
}) async {
  await tester.fling(scrollView, const Offset(0, -700), 1400);
  await _pumpDiagnosticFrames(tester, durationPumps: durationPumps);
}

Future<void> _pumpDiagnosticFrames(
  WidgetTester tester, {
  required int durationPumps,
}) async {
  for (var frame = 0; frame < durationPumps; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<Map<String, Object?>> _watchDiagnosticFrameTrace({
  required IntegrationTestWidgetsFlutterBinding binding,
  required String reportKey,
  required Future<void> Function() action,
}) async {
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
  binding.reportData!.remove(reportKey);

  final buildTimesMs = buildMicros.map((value) => value / 1000).toList();
  final rasterTimesMs = rasterMicros.map((value) => value / 1000).toList();
  final frameTimesMs = <double>[
    for (var index = 0; index < buildTimesMs.length; index++)
      math.max(buildTimesMs[index], rasterTimesMs[index]),
  ];
  final droppedFrames = frameTimesMs
      .where(
        (value) =>
            value > PerformanceTargets.frameBudget60Fps.inMicroseconds / 1000,
      )
      .length;

  return <String, Object?>{
    'frame_count': frameTimesMs.length,
    'frame_times_ms': frameTimesMs,
    'build_times_ms': buildTimesMs,
    'raster_times_ms': rasterTimesMs,
    'average_frame_time_ms': _average(frameTimesMs),
    'median_frame_time_ms': _median(frameTimesMs),
    'dropped_frames': droppedFrames,
    'dropped_frame_percentage': droppedFrames * 100 / frameTimesMs.length,
    'average_build_time_ms': _average(buildTimesMs),
    'average_raster_time_ms': _average(rasterTimesMs),
  };
}

double _average(List<double> values) =>
    values.reduce((left, right) => left + right) / values.length;

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
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

class _MinimalPerformanceScrollSurface extends StatelessWidget {
  const _MinimalPerformanceScrollSurface();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView.builder(
      key: _minimalScrollKey,
      itemCount: 200,
      itemExtent: 56,
      itemBuilder: (context, index) => SizedBox(
        height: 56,
        child: ColoredBox(
          color: index.isEven ? Colors.white : const Color(0xFFF7F7F7),
        ),
      ),
    ),
  );
}
