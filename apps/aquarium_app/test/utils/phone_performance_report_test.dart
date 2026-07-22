import 'package:danio/utils/performance_targets.dart';
import 'package:danio/utils/phone_performance_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const commit = '0123456789abcdef0123456789abcdef01234567';
  const device = 'danio_api36 (emulator-5554)';
  final generatedAt = DateTime.utc(2026, 7, 22, 12, 30);

  group('PhonePerformanceReport', () {
    test('summarizes the exact latency and trace sample contract', () {
      final report = PhonePerformanceReport.summarize(
        _completePassingRuns(
          commit: commit,
          device: device,
          failingTank: true,
        ),
        generatedAt: generatedAt,
      );

      expect(report.productCommit, commit);
      expect(report.device, device);
      final startup = report.resultFor(
        DanioPerformanceScenario.coldStartTank,
      );
      expect(startup.sampleCount, 5);
      expect(startup.samplesMs, [1200, 1300, 1400, 1500, 1600]);
      expect(startup.medianMs, 1400);
      expect(startup.budget.maxLatencyMs, 2500);
      expect(startup.passed, isTrue);

      final tank = report.resultFor(
        DanioPerformanceScenario.tankAnimation,
      );
      expect(tank.traceCount, 3);
      expect(tank.totalFrames, 6);
      expect(tank.averageFrameTimeMs, closeTo(13.5, 0.0001));
      expect(tank.medianFrameTimeMs, closeTo(13.5, 0.0001));
      expect(tank.droppedFrames, 1);
      expect(tank.droppedFramePercentage, closeTo(16.6667, 0.0001));
      expect(tank.budget.maxAverageFrameTimeMs, 16.667);
      expect(tank.budget.maxDroppedFramePercentage, 5);
      expect(tank.passed, isFalse);
      expect(report.passed, isFalse);
    });

    test('emits the required machine-readable identity and statistics', () {
      final report = PhonePerformanceReport.summarize(
        _completePassingRuns(commit: commit, device: device),
        generatedAt: generatedAt,
      );

      final json = report.toJson();
      expect(json['schema_version'], 1);
      expect(json['product_commit'], commit);
      expect(json['device'], device);
      expect(json['generated_at_utc'], '2026-07-22T12:30:00.000Z');
      expect(json['passed'], isTrue);

      final scenarios = json['scenarios']! as List<Object?>;
      expect(scenarios, hasLength(6));
      final scrolling = scenarios.cast<Map<String, Object?>>().singleWhere(
        (scenario) => scenario['scenario'] == 'scrolling',
      );
      expect(scrolling['trace_count'], 3);
      expect(scrolling['average_frame_time_ms'], isA<double>());
      expect(scrolling['median_frame_time_ms'], isA<double>());
      expect(scrolling['dropped_frame_percentage'], isA<double>());
      expect(scrolling['budget'], isA<Map<String, Object?>>());
      expect(scrolling['passed'], isTrue);
    });

    test('uses the 60 FPS threshold for scrolling dropped frames', () {
      final runs = _completePassingRuns(commit: commit, device: device);
      final interactionRun = runs.last;
      runs[runs.length - 1] = PhonePerformanceRun(
        productCommit: commit,
        device: device,
        records: interactionRun.records.map((record) {
          if (record.scenario != DanioPerformanceScenario.mainScrolling) {
            return record;
          }
          return PhonePerformanceRecord.frameTrace(
            scenario: record.scenario,
            traceIndex: record.traceIndex!,
            frameTimesMs: const [16.668, 19.0],
          );
        }).toList(),
      );

      final scrolling = PhonePerformanceReport.summarize(
        runs,
        generatedAt: generatedAt,
      ).resultFor(DanioPerformanceScenario.mainScrolling);

      expect(scrolling.averageFrameTimeMs, closeTo(17.834, 0.0001));
      expect(scrolling.droppedFrames, 6);
      expect(scrolling.droppedFramePercentage, 100);
      expect(scrolling.passed, isFalse);
    });

    test('rejects missing warm-up, measured samples, or traces', () {
      final runs = _completePassingRuns(commit: commit, device: device);
      final withoutWarmup = runs
          .map(
            (run) => PhonePerformanceRun(
              productCommit: run.productCommit,
              device: run.device,
              records: run.records
                  .where(
                    (record) =>
                        record.scenario !=
                            DanioPerformanceScenario.warmResume ||
                        !record.warmUp,
                  )
                  .toList(),
            ),
          )
          .toList();

      expect(
        () => PhonePerformanceReport.summarize(
          withoutWarmup,
          generatedAt: generatedAt,
        ),
        throwsA(isA<FormatException>()),
      );

      final missingTrace = _completePassingRuns(
        commit: commit,
        device: device,
      );
      final interactionRun = missingTrace.last;
      missingTrace[missingTrace.length - 1] = PhonePerformanceRun(
        productCommit: commit,
        device: device,
        records: interactionRun.records.where((record) {
          if (record.scenario != DanioPerformanceScenario.mainScrolling) {
            return true;
          }
          return record.traceIndex != 3;
        }).toList(),
      );

      expect(
        () => PhonePerformanceReport.summarize(
          missingTrace,
          generatedAt: generatedAt,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects mixed commit or device identities', () {
      final runs = _completePassingRuns(commit: commit, device: device);
      runs.add(
        PhonePerformanceRun(
          productCommit: 'fedcba9876543210fedcba9876543210fedcba98',
          device: device,
          records: const [],
        ),
      );

      expect(
        () => PhonePerformanceReport.summarize(
          runs,
          generatedAt: generatedAt,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed identity and non-finite samples', () {
      final malformedCommit = _completePassingRuns(
        commit: 'not-a-commit',
        device: device,
      );
      expect(
        () => PhonePerformanceReport.summarize(
          malformedCommit,
          generatedAt: generatedAt,
        ),
        throwsA(isA<FormatException>()),
      );

      final invalidSamples = _completePassingRuns(
        commit: commit,
        device: device,
      );
      final interactionRun = invalidSamples.last;
      invalidSamples[invalidSamples.length - 1] = PhonePerformanceRun(
        productCommit: commit,
        device: device,
        records: interactionRun.records.map((record) {
          if (record.scenario == DanioPerformanceScenario.warmResume &&
              !record.warmUp) {
            return PhonePerformanceRecord.latency(
              scenario: record.scenario,
              samplesMs: const [double.nan, 11, 12, 13, 14],
            );
          }
          return record;
        }).toList(),
      );

      expect(
        () => PhonePerformanceReport.summarize(
          invalidSamples,
          generatedAt: generatedAt,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('round trips raw integration response data', () {
      final original = _completePassingRuns(
        commit: commit,
        device: device,
      ).first;

      final restored = PhonePerformanceRun.fromJson(original.toJson());

      expect(restored.toJson(), original.toJson());
    });

    test('rejects missing or unknown raw schema versions', () {
      final raw = _completePassingRuns(
        commit: commit,
        device: device,
      ).first.toJson();

      expect(
        () => PhonePerformanceRun.fromJson({...raw}..remove('schema_version')),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => PhonePerformanceRun.fromJson({...raw, 'schema_version': 2}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => PhonePerformanceRun.fromJson({
          'data': {...raw, 'schema_version': 2},
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

List<PhonePerformanceRun> _completePassingRuns({
  required String commit,
  required String device,
  bool failingTank = false,
}) {
  final startupRuns = <PhonePerformanceRun>[];
  for (var iteration = 0; iteration < 6; iteration++) {
    startupRuns.add(
      PhonePerformanceRun(
        productCommit: commit,
        device: device,
        records: [
          PhonePerformanceRecord.latency(
            scenario: DanioPerformanceScenario.coldStartTank,
            warmUp: iteration == 0,
            samplesMs: [1100 + (iteration * 100)],
          ),
        ],
      ),
    );
  }

  final interactionRecords = <PhonePerformanceRecord>[];
  for (final scenario in const [
    DanioPerformanceScenario.warmResume,
    DanioPerformanceScenario.tabSwitch,
    DanioPerformanceScenario.imageLoading,
  ]) {
    interactionRecords.add(
      PhonePerformanceRecord.latency(
        scenario: scenario,
        warmUp: true,
        samplesMs: const [10],
      ),
    );
    interactionRecords.add(
      PhonePerformanceRecord.latency(
        scenario: scenario,
        samplesMs: const [10, 11, 12, 13, 14],
      ),
    );
  }

  for (final scenario in const [
    DanioPerformanceScenario.tankAnimation,
    DanioPerformanceScenario.mainScrolling,
  ]) {
    for (var trace = 1; trace <= 3; trace++) {
      final frameTimes =
          failingTank && scenario == DanioPerformanceScenario.tankAnimation
          ? switch (trace) {
              1 => const [8.0, 9.0],
              2 => const [13.0, 14.0],
              _ => const [16.0, 21.0],
            }
          : const [8.0, 9.0];
      interactionRecords.add(
        PhonePerformanceRecord.frameTrace(
          scenario: scenario,
          traceIndex: trace,
          frameTimesMs: frameTimes,
        ),
      );
    }
  }

  return [
    ...startupRuns,
    PhonePerformanceRun(
      productCommit: commit,
      device: device,
      records: interactionRecords,
    ),
  ];
}
