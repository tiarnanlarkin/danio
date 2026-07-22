Map<String, Object?> unwrapPhonePerformanceAttributionRun(Object? value) {
  final response = value is Map<String, Object?>
      ? value
      : _stringMap(value, 'Flutter Driver response');
  final data = response['data'];
  if (data == null) return response;
  return data is Map<String, Object?>
      ? data
      : _stringMap(data, 'Flutter Driver response data');
}

Map<String, Object?> summarizePhonePerformanceAttribution(
  List<Map<String, Object?>> runs, {
  required DateTime generatedAt,
}) {
  final interactionRuns = runs
      .where(
        (run) => run['diagnostic'] == 'paired_profile_attribution_interactions',
      )
      .toList();
  final imageRuns = runs
      .where(
        (run) => run['diagnostic'] == 'paired_profile_attribution_image',
      )
      .toList();
  if (interactionRuns.length != 1 || imageRuns.length != 6) {
    throw const FormatException(
      'Attribution evidence requires one interaction run and six image runs.',
    );
  }

  final identity = _identityFor(runs.first);
  for (final run in runs) {
    final candidate = _identityFor(run);
    if (candidate.productCommit != identity.productCommit ||
        candidate.device != identity.device) {
      throw const FormatException(
        'Attribution runs must use one product commit and device.',
      );
    }
  }

  final interactions = interactionRuns.single;
  final tankPairs = _mapList(
    interactions['tank_feedback_pairs'],
    'tank_feedback_pairs',
  );
  final scrollingPairs = _mapList(
    interactions['scrolling_pairs'],
    'scrolling_pairs',
  );
  _expectPairIndexes(tankPairs, 'tank_feedback_pairs');
  _expectPairIndexes(scrollingPairs, 'scrolling_pairs');

  final tankDuration = _sharedInt(
    tankPairs,
    'duration_pumps_per_trace',
    'tank_feedback_pairs',
  );
  final scrollDuration = _sharedInt(
    scrollingPairs,
    'duration_pumps_per_trace',
    'scrolling_pairs',
  );
  final flingOffset = _sharedDouble(
    scrollingPairs,
    'fling_offset_dy',
    'scrolling_pairs',
  );
  final flingVelocity = _sharedDouble(
    scrollingPairs,
    'fling_velocity',
    'scrolling_pairs',
  );

  final tankIdle = tankPairs
      .map((pair) => _trace(pair['idle'], 'tank idle'))
      .toList();
  final tankFeeding = tankPairs
      .map((pair) => _trace(pair['feeding'], 'tank feeding'))
      .toList();
  final learnScroll = scrollingPairs
      .map((pair) => _trace(pair['learn'], 'Learn scrolling'))
      .toList();
  final minimalScroll = scrollingPairs
      .map((pair) => _trace(pair['minimal'], 'minimal scrolling'))
      .toList();

  final imageSamples =
      imageRuns.map((run) => _stringMap(run['sample'], 'sample')).toList()
        ..sort(
          (left, right) => _int(left['iteration'], 'iteration').compareTo(
            _int(right['iteration'], 'iteration'),
          ),
        );
  for (var iteration = 0; iteration < 6; iteration++) {
    final sample = imageSamples[iteration];
    if (_int(sample['iteration'], 'iteration') != iteration ||
        _bool(sample['warm_up'], 'warm_up') != (iteration == 0)) {
      throw const FormatException(
        'Image attribution samples must be iterations 0..5 with only 0 warm-up.',
      );
    }
    final navigation = _double(
      sample['navigation_start_ms'],
      'navigation_start_ms',
    );
    final mount = _double(sample['mount_ready_ms'], 'mount_ready_ms');
    final decode = _double(sample['decode_ready_ms'], 'decode_ready_ms');
    final paint = _double(sample['paint_ready_ms'], 'paint_ready_ms');
    if (navigation < 0 ||
        mount < navigation ||
        decode < mount ||
        paint < decode) {
      throw const FormatException(
        'Image phase timestamps must be non-negative and monotonic.',
      );
    }
    _string(sample['asset_name'], 'asset_name');
  }
  final measuredImages = imageSamples.skip(1).toList();

  final idleAverage = _traceMean(tankIdle, 'average_frame_time_ms');
  final feedingAverage = _traceMean(
    tankFeeding,
    'average_frame_time_ms',
  );
  final learnAverage = _traceMean(learnScroll, 'average_frame_time_ms');
  final minimalAverage = _traceMean(
    minimalScroll,
    'average_frame_time_ms',
  );

  return <String, Object?>{
    'schema_version': 1,
    'diagnostic': 'paired_profile_attribution',
    'product_commit': identity.productCommit,
    'device': identity.device,
    'profile_mode': true,
    'generated_at_utc': generatedAt.toUtc().toIso8601String(),
    'tank_feedback_comparison': <String, Object?>{
      'pair_count': tankPairs.length,
      'order': 'idle_then_feeding',
      'duration_pumps_per_trace': tankDuration,
      'nominal_duration_ms_per_trace': tankDuration * 16,
      'idle_average_frame_time_ms': idleAverage,
      'feeding_average_frame_time_ms': feedingAverage,
      'incremental_average_frame_time_ms': feedingAverage - idleAverage,
      'idle_dropped_frame_percentage': _traceMean(
        tankIdle,
        'dropped_frame_percentage',
      ),
      'feeding_dropped_frame_percentage': _traceMean(
        tankFeeding,
        'dropped_frame_percentage',
      ),
      'idle_average_build_time_ms': _traceMean(
        tankIdle,
        'average_build_time_ms',
      ),
      'feeding_average_build_time_ms': _traceMean(
        tankFeeding,
        'average_build_time_ms',
      ),
      'idle_average_raster_time_ms': _traceMean(
        tankIdle,
        'average_raster_time_ms',
      ),
      'feeding_average_raster_time_ms': _traceMean(
        tankFeeding,
        'average_raster_time_ms',
      ),
      'pairs': tankPairs,
    },
    'scrolling_comparison': <String, Object?>{
      'pair_count': scrollingPairs.length,
      'order': 'learn_then_minimal',
      'duration_pumps_per_trace': scrollDuration,
      'nominal_duration_ms_per_trace': scrollDuration * 16,
      'fling_offset_dy': flingOffset,
      'fling_velocity': flingVelocity,
      'learn_average_frame_time_ms': learnAverage,
      'minimal_average_frame_time_ms': minimalAverage,
      'incremental_average_frame_time_ms': learnAverage - minimalAverage,
      'learn_dropped_frame_percentage': _traceMean(
        learnScroll,
        'dropped_frame_percentage',
      ),
      'minimal_dropped_frame_percentage': _traceMean(
        minimalScroll,
        'dropped_frame_percentage',
      ),
      'learn_average_build_time_ms': _traceMean(
        learnScroll,
        'average_build_time_ms',
      ),
      'minimal_average_build_time_ms': _traceMean(
        minimalScroll,
        'average_build_time_ms',
      ),
      'learn_average_raster_time_ms': _traceMean(
        learnScroll,
        'average_raster_time_ms',
      ),
      'minimal_average_raster_time_ms': _traceMean(
        minimalScroll,
        'average_raster_time_ms',
      ),
      'pairs': scrollingPairs,
    },
    'image_phase_timestamps': <String, Object?>{
      'sample_count': imageSamples.length,
      'measured_sample_count': measuredImages.length,
      'mount_ready_median_ms': _median(
        measuredImages
            .map(
              (sample) => _double(sample['mount_ready_ms'], 'mount_ready_ms'),
            )
            .toList(),
      ),
      'decode_ready_median_ms': _median(
        measuredImages
            .map(
              (sample) => _double(sample['decode_ready_ms'], 'decode_ready_ms'),
            )
            .toList(),
      ),
      'paint_ready_median_ms': _median(
        measuredImages
            .map(
              (sample) => _double(sample['paint_ready_ms'], 'paint_ready_ms'),
            )
            .toList(),
      ),
      'samples': imageSamples,
    },
  };
}

({String productCommit, String device}) _identityFor(
  Map<String, Object?> run,
) {
  if (_int(run['schema_version'], 'schema_version') != 1 ||
      !_bool(run['profile_mode'], 'profile_mode')) {
    throw const FormatException(
      'Attribution evidence must be schema 1 profile-mode data.',
    );
  }
  final productCommit = _string(run['product_commit'], 'product_commit');
  final device = _string(run['device'], 'device');
  if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(productCommit) ||
      !device.startsWith('danio_api36 (')) {
    throw const FormatException(
      'Attribution evidence must identify the product commit and owned device.',
    );
  }
  return (productCommit: productCommit, device: device);
}

void _expectPairIndexes(List<Map<String, Object?>> pairs, String label) {
  if (pairs.length != 3) {
    throw FormatException('$label requires exactly three pairs.');
  }
  for (var index = 0; index < pairs.length; index++) {
    if (_int(pairs[index]['pair_index'], 'pair_index') != index + 1) {
      throw FormatException('$label pair indexes must be 1, 2, 3.');
    }
  }
}

int _sharedInt(
  List<Map<String, Object?>> values,
  String key,
  String label,
) {
  final result = _int(values.first[key], key);
  if (result <= 0 || values.any((value) => _int(value[key], key) != result)) {
    throw FormatException('$label must share one positive $key.');
  }
  return result;
}

double _sharedDouble(
  List<Map<String, Object?>> values,
  String key,
  String label,
) {
  final result = _double(values.first[key], key);
  if (values.any((value) => _double(value[key], key) != result)) {
    throw FormatException('$label must share one $key.');
  }
  return result;
}

Map<String, Object?> _trace(Object? value, String label) {
  final trace = _stringMap(value, label);
  for (final key in [
    'average_frame_time_ms',
    'median_frame_time_ms',
    'dropped_frame_percentage',
    'average_build_time_ms',
    'average_raster_time_ms',
  ]) {
    _double(trace[key], '$label.$key');
  }
  if (_int(trace['frame_count'], '$label.frame_count') <= 0 ||
      _int(trace['dropped_frames'], '$label.dropped_frames') < 0) {
    throw FormatException('$label contains invalid frame counts.');
  }
  return trace;
}

double _traceMean(List<Map<String, Object?>> traces, String key) =>
    traces.map((trace) => _double(trace[key], key)).reduce((a, b) => a + b) /
    traces.length;

double _median(List<double> values) {
  if (values.isEmpty) throw const FormatException('Median requires values.');
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

List<Map<String, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('$label must be a list.');
  return value.map((item) => _stringMap(item, label)).toList();
}

Map<String, Object?> _stringMap(Object? value, String label) {
  if (value is! Map<Object?, Object?>) {
    throw FormatException('$label must be an object.');
  }
  if (value.keys.any((key) => key is! String)) {
    throw FormatException('$label keys must be strings.');
  }
  return value.cast<String, Object?>();
}

String _string(Object? value, String label) {
  if (value is! String || value.isEmpty) {
    throw FormatException('$label must be a non-empty string.');
  }
  return value;
}

bool _bool(Object? value, String label) {
  if (value is! bool) throw FormatException('$label must be a boolean.');
  return value;
}

int _int(Object? value, String label) {
  if (value is! int) throw FormatException('$label must be an integer.');
  return value;
}

double _double(Object? value, String label) {
  if (value is! num || !value.toDouble().isFinite) {
    throw FormatException('$label must be a finite number.');
  }
  return value.toDouble();
}
