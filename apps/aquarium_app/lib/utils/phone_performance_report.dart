import 'performance_targets.dart';

const phonePerformanceReportSchemaVersion = 1;

/// One raw latency sample group or frame trace emitted by the phone harness.
class PhonePerformanceRecord {
  const PhonePerformanceRecord._({
    required this.scenario,
    required this.metric,
    required this.warmUp,
    required this.samplesMs,
    this.traceIndex,
    this.buildTimesMs = const [],
    this.rasterTimesMs = const [],
  });

  factory PhonePerformanceRecord.latency({
    required DanioPerformanceScenario scenario,
    bool warmUp = false,
    required List<num> samplesMs,
  }) {
    return PhonePerformanceRecord._(
      scenario: scenario,
      metric: PhonePerformanceMetric.latency,
      warmUp: warmUp,
      samplesMs: samplesMs.map((value) => value.toDouble()).toList(),
    );
  }

  factory PhonePerformanceRecord.frameTrace({
    required DanioPerformanceScenario scenario,
    required int traceIndex,
    required List<num> frameTimesMs,
    List<num> buildTimesMs = const [],
    List<num> rasterTimesMs = const [],
  }) {
    return PhonePerformanceRecord._(
      scenario: scenario,
      metric: PhonePerformanceMetric.frameTrace,
      warmUp: false,
      samplesMs: frameTimesMs.map((value) => value.toDouble()).toList(),
      traceIndex: traceIndex,
      buildTimesMs: buildTimesMs.map((value) => value.toDouble()).toList(),
      rasterTimesMs: rasterTimesMs.map((value) => value.toDouble()).toList(),
    );
  }

  factory PhonePerformanceRecord.fromJson(Map<String, Object?> json) {
    final samples = json['samples_ms'];
    if (samples is! List<Object?>) {
      throw const FormatException('Performance record has no samples_ms list.');
    }

    return PhonePerformanceRecord._(
      scenario: _scenarioFromWireName(json['scenario'] as String? ?? ''),
      metric: PhonePerformanceMetric.fromWireName(
        json['metric'] as String? ?? '',
      ),
      warmUp: json['warm_up'] as bool? ?? false,
      samplesMs: samples.map((value) {
        if (value is! num) {
          throw const FormatException(
            'Performance samples must be numeric.',
          );
        }
        return value.toDouble();
      }).toList(),
      traceIndex: (json['trace_index'] as num?)?.toInt(),
      buildTimesMs: _optionalNumericList(json, 'build_times_ms'),
      rasterTimesMs: _optionalNumericList(json, 'raster_times_ms'),
    );
  }

  final DanioPerformanceScenario scenario;
  final PhonePerformanceMetric metric;
  final bool warmUp;
  final List<double> samplesMs;
  final int? traceIndex;
  final List<double> buildTimesMs;
  final List<double> rasterTimesMs;

  Map<String, Object?> toJson() => {
    'scenario': scenario.wireName,
    'metric': metric.wireName,
    'warm_up': warmUp,
    'samples_ms': samplesMs,
    if (traceIndex != null) 'trace_index': traceIndex,
    if (buildTimesMs.isNotEmpty) 'build_times_ms': buildTimesMs,
    if (rasterTimesMs.isNotEmpty) 'raster_times_ms': rasterTimesMs,
  };
}

enum PhonePerformanceMetric {
  latency('latency_ms'),
  frameTrace('frame_times_ms');

  const PhonePerformanceMetric(this.wireName);

  final String wireName;

  static PhonePerformanceMetric fromWireName(String value) {
    return PhonePerformanceMetric.values.singleWhere(
      (metric) => metric.wireName == value,
      orElse: () => throw FormatException(
        'Unknown phone performance metric "$value".',
      ),
    );
  }
}

/// Raw data from one profile-mode integration-test invocation.
class PhonePerformanceRun {
  const PhonePerformanceRun({
    required this.productCommit,
    required this.device,
    required this.records,
  });

  factory PhonePerformanceRun.fromJson(Map<String, Object?> json) {
    final wrappedData = json['data'];
    final Map<String, Object?> unwrapped;
    if (wrappedData is Map<Object?, Object?>) {
      unwrapped = wrappedData.cast<String, Object?>();
    } else {
      unwrapped = json;
    }
    if (unwrapped['schema_version'] != phonePerformanceReportSchemaVersion) {
      throw FormatException(
        'Performance run schema_version must be '
        '$phonePerformanceReportSchemaVersion.',
      );
    }
    final records = unwrapped['records'];
    if (records is! List<Object?>) {
      throw const FormatException('Performance run has no records list.');
    }

    return PhonePerformanceRun(
      productCommit: _requiredString(unwrapped, 'product_commit'),
      device: _requiredString(unwrapped, 'device'),
      records: records.map((record) {
        if (record is! Map<Object?, Object?>) {
          throw const FormatException(
            'Performance records must be JSON objects.',
          );
        }
        return PhonePerformanceRecord.fromJson(
          record.cast<String, Object?>(),
        );
      }).toList(),
    );
  }

  final String productCommit;
  final String device;
  final List<PhonePerformanceRecord> records;

  Map<String, Object?> toJson() => {
    'schema_version': phonePerformanceReportSchemaVersion,
    'product_commit': productCommit,
    'device': device,
    'records': records.map((record) => record.toJson()).toList(),
  };
}

/// A normalized, budgeted report for all six phone scenarios.
class PhonePerformanceReport {
  const PhonePerformanceReport._({
    required this.productCommit,
    required this.device,
    required this.generatedAt,
    required this.scenarios,
  });

  factory PhonePerformanceReport.summarize(
    List<PhonePerformanceRun> runs, {
    required DateTime generatedAt,
  }) {
    if (runs.isEmpty) {
      throw const FormatException('No phone performance runs were supplied.');
    }

    final productCommit = runs.first.productCommit;
    final device = runs.first.device;
    if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(productCommit) || device.isEmpty) {
      throw const FormatException(
        'Performance identity requires a product commit and device.',
      );
    }
    for (final run in runs.skip(1)) {
      if (run.productCommit != productCommit || run.device != device) {
        throw const FormatException(
          'Performance runs mix product commits or device identities.',
        );
      }
    }

    final records = runs.expand((run) => run.records).toList();
    final results = <PhonePerformanceScenarioResult>[];
    for (final scenario in DanioPerformanceScenario.values) {
      final scenarioRecords = records
          .where((record) => record.scenario == scenario)
          .toList();
      results.add(
        switch (scenario) {
          DanioPerformanceScenario.coldStartTank ||
          DanioPerformanceScenario.warmResume ||
          DanioPerformanceScenario.tabSwitch ||
          DanioPerformanceScenario.imageLoading =>
            PhonePerformanceScenarioResult.fromLatency(
              scenario,
              scenarioRecords,
            ),
          DanioPerformanceScenario.tankAnimation ||
          DanioPerformanceScenario.mainScrolling =>
            PhonePerformanceScenarioResult.fromFrameTraces(
              scenario,
              scenarioRecords,
            ),
        },
      );
    }

    return PhonePerformanceReport._(
      productCommit: productCommit,
      device: device,
      generatedAt: generatedAt.toUtc(),
      scenarios: results,
    );
  }

  final String productCommit;
  final String device;
  final DateTime generatedAt;
  final List<PhonePerformanceScenarioResult> scenarios;

  bool get passed => scenarios.every((scenario) => scenario.passed);

  PhonePerformanceScenarioResult resultFor(
    DanioPerformanceScenario scenario,
  ) => scenarios.singleWhere((result) => result.scenario == scenario);

  Map<String, Object?> toJson() => {
    'schema_version': phonePerformanceReportSchemaVersion,
    'product_commit': productCommit,
    'device': device,
    'generated_at_utc': generatedAt.toIso8601String(),
    'passed': passed,
    'scenarios': scenarios.map((scenario) => scenario.toJson()).toList(),
  };
}

class PhonePerformanceScenarioResult {
  const PhonePerformanceScenarioResult._({
    required this.scenario,
    required this.budget,
    required this.passed,
    this.samplesMs = const [],
    this.medianMs,
    this.traceCount = 0,
    this.traceAverageFrameTimesMs = const [],
    this.totalFrames = 0,
    this.averageFrameTimeMs,
    this.medianFrameTimeMs,
    this.droppedFrames = 0,
    this.droppedFramePercentage,
  });

  factory PhonePerformanceScenarioResult.fromLatency(
    DanioPerformanceScenario scenario,
    List<PhonePerformanceRecord> records,
  ) {
    if (records.any(
      (record) => record.metric != PhonePerformanceMetric.latency,
    )) {
      throw FormatException('${scenario.wireName} contains non-latency data.');
    }

    final warmups = records.where((record) => record.warmUp).toList();
    final measured = records.where((record) => !record.warmUp).toList();
    final warmupSamples = warmups.expand((record) => record.samplesMs).toList();
    final samples = measured.expand((record) => record.samplesMs).toList();
    if (warmupSamples.length != 1 || samples.length != 5) {
      throw FormatException(
        '${scenario.wireName} requires one warm-up and five measured samples.',
      );
    }
    _validateSamples(samples, scenario);

    final budget = PhonePerformanceBudgetSnapshot.forScenario(scenario);
    final median = _median(samples);
    final maximum = budget.maxLatencyMs ?? budget.maxBlankImageTimeMs;
    if (maximum == null) {
      throw FormatException('${scenario.wireName} has no latency budget.');
    }

    return PhonePerformanceScenarioResult._(
      scenario: scenario,
      budget: budget,
      samplesMs: samples,
      medianMs: median,
      passed: median <= maximum,
    );
  }

  factory PhonePerformanceScenarioResult.fromFrameTraces(
    DanioPerformanceScenario scenario,
    List<PhonePerformanceRecord> records,
  ) {
    if (records.length != 3 ||
        records.any(
          (record) =>
              record.metric != PhonePerformanceMetric.frameTrace ||
              record.warmUp ||
              record.traceIndex == null,
        )) {
      throw FormatException(
        '${scenario.wireName} requires three measured frame traces.',
      );
    }
    final indices = records.map((record) => record.traceIndex).toSet();
    if (!indices.containsAll(const {1, 2, 3}) || indices.length != 3) {
      throw FormatException(
        '${scenario.wireName} frame traces must be numbered 1 through 3.',
      );
    }

    for (final record in records) {
      _validateSamples(record.samplesMs, scenario);
      if ((record.buildTimesMs.isNotEmpty || record.rasterTimesMs.isNotEmpty) &&
          (record.buildTimesMs.length != record.samplesMs.length ||
              record.rasterTimesMs.length != record.samplesMs.length)) {
        throw FormatException(
          '${scenario.wireName} raw build/raster arrays do not match frames.',
        );
      }
    }
    final ordered = [...records]
      ..sort((a, b) => a.traceIndex!.compareTo(b.traceIndex!));
    final frames = ordered.expand((record) => record.samplesMs).toList();
    final traceAverages = ordered
        .map((record) => _average(record.samplesMs))
        .toList();
    final budget = PhonePerformanceBudgetSnapshot.forScenario(scenario);
    final frameBudget = budget.maxAverageFrameTimeMs;
    final droppedBudget = budget.maxDroppedFramePercentage;
    if (frameBudget == null || droppedBudget == null) {
      throw FormatException('${scenario.wireName} has no frame budget.');
    }
    final average = _average(frames);
    final droppedFrameThresholdMs = _durationMs(
      PerformanceTargets.frameBudget60Fps,
    )!;
    final dropped = frames
        .where((frame) => frame > droppedFrameThresholdMs)
        .length;
    final droppedPercentage = (dropped / frames.length) * 100;

    return PhonePerformanceScenarioResult._(
      scenario: scenario,
      budget: budget,
      passed: average <= frameBudget && droppedPercentage <= droppedBudget,
      traceCount: ordered.length,
      traceAverageFrameTimesMs: traceAverages,
      totalFrames: frames.length,
      averageFrameTimeMs: average,
      medianFrameTimeMs: _median(frames),
      droppedFrames: dropped,
      droppedFramePercentage: droppedPercentage,
    );
  }

  final DanioPerformanceScenario scenario;
  final PhonePerformanceBudgetSnapshot budget;
  final bool passed;
  final List<double> samplesMs;
  int get sampleCount => samplesMs.length;
  final double? medianMs;
  final int traceCount;
  final List<double> traceAverageFrameTimesMs;
  final int totalFrames;
  final double? averageFrameTimeMs;
  final double? medianFrameTimeMs;
  final int droppedFrames;
  final double? droppedFramePercentage;

  Map<String, Object?> toJson() => {
    'scenario': scenario.wireName,
    'label': PerformanceTargets.budgetFor(scenario).label,
    'sample_count': sampleCount,
    if (samplesMs.isNotEmpty) 'samples_ms': samplesMs,
    if (medianMs != null) 'median_ms': medianMs,
    if (traceCount > 0) 'trace_count': traceCount,
    if (traceAverageFrameTimesMs.isNotEmpty)
      'trace_average_frame_times_ms': traceAverageFrameTimesMs,
    if (totalFrames > 0) 'total_frames': totalFrames,
    if (averageFrameTimeMs != null) 'average_frame_time_ms': averageFrameTimeMs,
    if (medianFrameTimeMs != null) 'median_frame_time_ms': medianFrameTimeMs,
    if (traceCount > 0) 'dropped_frames': droppedFrames,
    if (droppedFramePercentage != null)
      'dropped_frame_percentage': droppedFramePercentage,
    'budget': budget.toJson(),
    'passed': passed,
  };
}

class PhonePerformanceBudgetSnapshot {
  const PhonePerformanceBudgetSnapshot({
    this.maxLatencyMs,
    this.maxAverageFrameTimeMs,
    this.maxDroppedFramePercentage,
    this.maxBlankImageTimeMs,
  });

  factory PhonePerformanceBudgetSnapshot.forScenario(
    DanioPerformanceScenario scenario,
  ) {
    final budget = PerformanceTargets.budgetFor(scenario);
    return PhonePerformanceBudgetSnapshot(
      maxLatencyMs: _durationMs(budget.maxLatency),
      maxAverageFrameTimeMs: _durationMs(budget.maxAverageFrameTime),
      maxDroppedFramePercentage: budget.maxDroppedFramePercentage,
      maxBlankImageTimeMs: _durationMs(budget.maxBlankImageTime),
    );
  }

  final double? maxLatencyMs;
  final double? maxAverageFrameTimeMs;
  final double? maxDroppedFramePercentage;
  final double? maxBlankImageTimeMs;

  Map<String, Object?> toJson() => {
    if (maxLatencyMs != null) 'max_latency_ms': maxLatencyMs,
    if (maxAverageFrameTimeMs != null)
      'max_average_frame_time_ms': maxAverageFrameTimeMs,
    if (maxDroppedFramePercentage != null)
      'max_dropped_frame_percentage': maxDroppedFramePercentage,
    if (maxBlankImageTimeMs != null)
      'max_blank_image_time_ms': maxBlankImageTimeMs,
  };
}

extension PhonePerformanceScenarioWireName on DanioPerformanceScenario {
  String get wireName => switch (this) {
    DanioPerformanceScenario.coldStartTank => 'cold_start',
    DanioPerformanceScenario.warmResume => 'warm_resume',
    DanioPerformanceScenario.tabSwitch => 'tab_switching',
    DanioPerformanceScenario.tankAnimation => 'tank_feedback',
    DanioPerformanceScenario.mainScrolling => 'scrolling',
    DanioPerformanceScenario.imageLoading => 'local_image_first_paint',
  };
}

DanioPerformanceScenario _scenarioFromWireName(String value) {
  return DanioPerformanceScenario.values.singleWhere(
    (scenario) => scenario.wireName == value,
    orElse: () => throw FormatException(
      'Unknown phone performance scenario "$value".',
    ),
  );
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Performance run has no $key.');
  }
  return value;
}

void _validateSamples(
  List<double> samples,
  DanioPerformanceScenario scenario,
) {
  if (samples.isEmpty ||
      samples.any((sample) => !sample.isFinite || sample < 0)) {
    throw FormatException('${scenario.wireName} contains invalid samples.');
  }
}

List<double> _optionalNumericList(
  Map<String, Object?> json,
  String key,
) {
  final values = json[key];
  if (values == null) return const [];
  if (values is! List<Object?>) {
    throw FormatException('$key must be a list.');
  }
  return values.map((value) {
    if (value is! num) {
      throw FormatException('$key must contain only numbers.');
    }
    return value.toDouble();
  }).toList();
}

double _average(List<double> values) {
  return values.reduce((a, b) => a + b) / values.length;
}

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final midpoint = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[midpoint];
  return (sorted[midpoint - 1] + sorted[midpoint]) / 2;
}

double? _durationMs(Duration? duration) {
  return duration == null ? null : duration.inMicroseconds / 1000;
}
