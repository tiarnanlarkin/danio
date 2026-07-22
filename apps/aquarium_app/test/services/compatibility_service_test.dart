import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/models.dart';
import 'package:danio/services/compatibility_service.dart';

final _now = DateTime(2026, 7, 22);

Tank _tank({
  double volumeLitres = 200,
  WaterTargets targets = const WaterTargets(),
}) => Tank(
  id: 'tank-1',
  name: 'Test Tank',
  type: TankType.freshwater,
  volumeLitres: volumeLitres,
  startDate: _now,
  targets: targets,
  createdAt: _now,
  updatedAt: _now,
);

Livestock _livestock(
  String commonName, {
  String id = 'candidate',
  int count = 1,
}) => Livestock(
  id: id,
  tankId: 'tank-1',
  commonName: commonName,
  count: count,
  dateAdded: _now,
  createdAt: _now,
  updatedAt: _now,
);

CompatibilityIssue _issue(CompatibilityLevel level) => CompatibilityIssue(
  level: level,
  title: level.name,
  description: 'Test issue',
);

void main() {
  group('CompatibilityService parameter rules', () {
    test(
      'temperature mismatches distinguish incompatible from edge warnings',
      () {
        final incompatible = CompatibilityService.checkLivestockCompatibility(
          livestock: _livestock('Neon Tetra', count: 6),
          tank: _tank(
            targets: const WaterTargets(tempMin: 30, tempMax: 32),
          ),
          existingLivestock: const [],
        );
        final edgeWarning = CompatibilityService.checkLivestockCompatibility(
          livestock: _livestock('Neon Tetra', count: 6),
          tank: _tank(
            targets: const WaterTargets(tempMin: 23, tempMax: 25),
          ),
          existingLivestock: const [],
        );

        expect(
          incompatible,
          contains(
            isA<CompatibilityIssue>()
                .having((issue) => issue.title, 'title', 'Temperature too high')
                .having(
                  (issue) => issue.level,
                  'level',
                  CompatibilityLevel.incompatible,
                ),
          ),
        );
        expect(
          edgeWarning,
          contains(
            isA<CompatibilityIssue>()
                .having(
                  (issue) => issue.title,
                  'title',
                  'Temperature at edge of range',
                )
                .having(
                  (issue) => issue.level,
                  'level',
                  CompatibilityLevel.warning,
                ),
          ),
        );
      },
    );

    test('pH mismatches distinguish incompatible from edge warnings', () {
      final incompatible = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Neon Tetra', count: 6),
        tank: _tank(targets: const WaterTargets(phMin: 8, phMax: 8.5)),
        existingLivestock: const [],
      );
      final edgeWarning = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Neon Tetra', count: 6),
        tank: _tank(targets: const WaterTargets(phMin: 6.5, phMax: 7)),
        existingLivestock: const [],
      );

      expect(
        incompatible,
        contains(
          isA<CompatibilityIssue>()
              .having((issue) => issue.title, 'title', 'pH too high')
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.incompatible,
              ),
        ),
      );
      expect(
        edgeWarning,
        contains(
          isA<CompatibilityIssue>()
              .having(
                (issue) => issue.title,
                'title',
                'pH at edge of comfort zone',
              )
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });

    test('GH outside the target is reported as a warning', () {
      final issues = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Neon Tetra', count: 6),
        tank: _tank(targets: const WaterTargets(ghMin: 13, ghMax: 16)),
        existingLivestock: const [],
      );

      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having((issue) => issue.title, 'title', 'Water may be too hard')
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });
  });

  group('CompatibilityService livestock rules', () {
    test('tank size and school size produce their expected severities', () {
      final issues = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Neon Tetra'),
        tank: _tank(volumeLitres: 20),
        existingLivestock: const [],
      );

      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having((issue) => issue.title, 'title', 'Tank may be too small')
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.incompatible,
              ),
        ),
      );
      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having((issue) => issue.title, 'title', 'Needs a larger school')
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });

    test('avoid lists report livestock conflicts', () {
      final issues = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Neon Tetra', count: 6),
        tank: _tank(),
        existingLivestock: [_livestock('Angelfish', id: 'existing')],
      );

      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having(
                (issue) => issue.title,
                'title',
                'Potential conflict with Angelfish',
              )
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });

    test('aggressive temperament against peaceful livestock is warned', () {
      final issues = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Convict Cichlid'),
        tank: _tank(),
        existingLivestock: [
          _livestock('Neon Tetra', id: 'existing', count: 6),
        ],
      );

      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having((issue) => issue.title, 'title', 'Temperament mismatch')
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });

    test('large size differences report predation risk', () {
      final issues = CompatibilityService.checkLivestockCompatibility(
        livestock: _livestock('Oscar'),
        tank: _tank(volumeLitres: 500),
        existingLivestock: [
          _livestock('Neon Tetra', id: 'existing', count: 6),
        ],
      );

      expect(
        issues,
        contains(
          isA<CompatibilityIssue>()
              .having(
                (issue) => issue.title,
                'title',
                'Size difference concern',
              )
              .having(
                (issue) => issue.suggestion,
                'suggestion',
                'Larger fish may see smaller ones as food.',
              )
              .having(
                (issue) => issue.level,
                'level',
                CompatibilityLevel.warning,
              ),
        ),
      );
    });
  });

  test('incompatible severity takes precedence over warnings', () {
    expect(
      CompatibilityService.overallLevel([
        _issue(CompatibilityLevel.warning),
        _issue(CompatibilityLevel.incompatible),
      ]),
      CompatibilityLevel.incompatible,
    );
    expect(
      CompatibilityService.overallLevel([
        _issue(CompatibilityLevel.warning),
      ]),
      CompatibilityLevel.warning,
    );
    expect(
      CompatibilityService.overallLevel(const []),
      CompatibilityLevel.compatible,
    );
  });
}
