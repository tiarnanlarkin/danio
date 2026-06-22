import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('visual baseline manifest', () {
    late String baselineSource;

    setUpAll(() {
      baselineSource = File('docs/design/BASELINES.md').readAsStringSync();
    });

    test('tracks the agreed small set of baseline surfaces', () {
      final tableRows = baselineSource
          .split('\n')
          .where((line) => line.startsWith('|'))
          .where((line) => !line.contains('---'))
          .where((line) => !line.contains('Surface |'))
          .toList();

      expect(tableRows, hasLength(lessThanOrEqualTo(8)));
      expect(
        baselineSource,
        contains('Capture no more than these eight app surfaces'),
      );

      for (final requiredSurface in [
        'Welcome/onboarding',
        'Home/tank dashboard',
        'Learn',
        'Practice',
        'Smart Hub',
        'Workshop',
        'Preferences',
        'Golden widgets',
      ]) {
        expect(
          baselineSource,
          contains(requiredSurface),
          reason: 'Missing visual baseline surface: $requiredSurface',
        );
      }
    });

    test('referenced screenshot and golden evidence exists locally', () {
      final inlineTargets = RegExp(
        r'`([^`]+)`',
      ).allMatches(baselineSource).map((match) => match.group(1)!).toSet();

      final screenshotTargets = inlineTargets
          .where((target) => target.endsWith('.png'))
          .toList();
      expect(screenshotTargets, hasLength(greaterThanOrEqualTo(7)));

      for (final target in screenshotTargets) {
        expect(
          File(target).existsSync(),
          isTrue,
          reason: 'Missing visual baseline screenshot: $target',
        );
      }

      expect(Directory('test/golden_tests').existsSync(), isTrue);
      expect(
        File('test/golden_tests/mc_card_golden_test.dart').existsSync(),
        isTrue,
      );
      expect(
        File('test/golden_tests/empty_room_scene_golden_test.dart').existsSync(),
        isTrue,
      );
    });

    test('local quality gate runs the manifest check by default', () {
      final gateSource = File(
        'scripts/quality_gates/run_local_quality_gate.ps1',
      ).readAsStringSync();

      expect(
        gateSource,
        contains('test/quality/visual_baseline_manifest_test.dart'),
      );
    });
  });
}
