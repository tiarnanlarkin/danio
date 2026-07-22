import 'package:flutter_test/flutter_test.dart';

import '../../tool/phone_performance_attribution_report.dart';

void main() {
  test('unwraps Flutter Driver response data before attribution parsing', () {
    final run = _interactionRun();

    expect(unwrapPhonePerformanceAttributionRun({'data': run}), same(run));
    expect(unwrapPhonePerformanceAttributionRun(run), same(run));
  });

  test('summarizes paired profile attribution without performance budgets', () {
    final report = summarizePhonePerformanceAttribution(
      [
        _interactionRun(),
        for (var iteration = 0; iteration < 6; iteration++)
          _imageRun(iteration),
      ],
      generatedAt: DateTime.utc(2026, 7, 22, 21, 30),
    );

    expect(report['schema_version'], 1);
    expect(report['diagnostic'], 'paired_profile_attribution');
    expect(report['product_commit'], _commit);
    expect(report['device'], _device);
    expect(report['profile_mode'], isTrue);
    expect(report, isNot(contains('passed')));
    expect(report, isNot(contains('budget')));

    final tank = report['tank_feedback_comparison'] as Map<String, Object?>;
    expect(tank['pair_count'], 3);
    expect(tank['duration_pumps_per_trace'], 60);
    expect(tank['idle_average_frame_time_ms'], closeTo(16, 0.001));
    expect(tank['feeding_average_frame_time_ms'], closeTo(24, 0.001));
    expect(tank['incremental_average_frame_time_ms'], closeTo(8, 0.001));

    final scrolling = report['scrolling_comparison'] as Map<String, Object?>;
    expect(scrolling['pair_count'], 3);
    expect(scrolling['duration_pumps_per_trace'], 45);
    expect(scrolling['fling_offset_dy'], -700.0);
    expect(scrolling['fling_velocity'], 1400.0);
    expect(scrolling['learn_average_frame_time_ms'], closeTo(28, 0.001));
    expect(scrolling['minimal_average_frame_time_ms'], closeTo(27, 0.001));
    expect(scrolling['incremental_average_frame_time_ms'], closeTo(1, 0.001));

    final image = report['image_phase_timestamps'] as Map<String, Object?>;
    expect(image['sample_count'], 6);
    expect(image['measured_sample_count'], 5);
    expect(image['mount_ready_median_ms'], 103.0);
    expect(image['decode_ready_median_ms'], 303.0);
    expect(image['paint_ready_median_ms'], 503.0);
    final samples = (image['samples'] as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(samples.first['warm_up'], isTrue);
    expect(
      samples.skip(1).every((sample) => sample['warm_up'] == false),
      isTrue,
    );
  });

  test('rejects incomplete or non-monotonic image phase evidence', () {
    expect(
      () => summarizePhonePerformanceAttribution(
        [
          _interactionRun(),
          for (var iteration = 0; iteration < 5; iteration++)
            _imageRun(iteration),
        ],
        generatedAt: DateTime.utc(2026, 7, 22),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => summarizePhonePerformanceAttribution(
        [
          _interactionRun(),
          for (var iteration = 0; iteration < 6; iteration++)
            if (iteration == 3)
              _imageRun(iteration, decodeReadyMs: 50)
            else
              _imageRun(iteration),
        ],
        generatedAt: DateTime.utc(2026, 7, 22),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}

const _commit = '0123456789abcdef0123456789abcdef01234567';
const _device = 'danio_api36 (emulator-5554)';

Map<String, Object?> _interactionRun() => {
  'schema_version': 1,
  'diagnostic': 'paired_profile_attribution_interactions',
  'product_commit': _commit,
  'device': _device,
  'profile_mode': true,
  'tank_feedback_pairs': [
    for (var pair = 1; pair <= 3; pair++)
      {
        'pair_index': pair,
        'duration_pumps_per_trace': 60,
        'idle': _trace(16),
        'feeding': _trace(24),
      },
  ],
  'scrolling_pairs': [
    for (var pair = 1; pair <= 3; pair++)
      {
        'pair_index': pair,
        'duration_pumps_per_trace': 45,
        'fling_offset_dy': -700.0,
        'fling_velocity': 1400.0,
        'learn': _trace(28),
        'minimal': _trace(27),
      },
  ],
};

Map<String, Object?> _imageRun(
  int iteration, {
  double? decodeReadyMs,
}) => {
  'schema_version': 1,
  'diagnostic': 'paired_profile_attribution_image',
  'product_commit': _commit,
  'device': _device,
  'profile_mode': true,
  'sample': {
    'iteration': iteration,
    'warm_up': iteration == 0,
    'navigation_start_ms': 0.0,
    'mount_ready_ms': 100.0 + iteration,
    'decode_ready_ms': decodeReadyMs ?? 300.0 + iteration,
    'paint_ready_ms': 500.0 + iteration,
    'asset_name': 'assets/images/headers/learn-header-test.webp',
  },
};

Map<String, Object?> _trace(double averageFrameTimeMs) => {
  'frame_count': 2,
  'average_frame_time_ms': averageFrameTimeMs,
  'median_frame_time_ms': averageFrameTimeMs,
  'dropped_frames': 1,
  'dropped_frame_percentage': 50.0,
  'average_build_time_ms': 4.0,
  'average_raster_time_ms': averageFrameTimeMs,
};
