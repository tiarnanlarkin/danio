import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('weekly progress copy avoids social leaderboard promises', () {
    final files = [
      'lib/models/leaderboard.dart',
      'lib/data/achievements.dart',
      'lib/services/analytics_service.dart',
    ];
    final oldCopy = RegExp(
      'Bronze League|Silver League|Gold League|Diamond League|'
      'League Climber|competitive spirit|promote to|secure your promotion',
      caseSensitive: false,
    );

    for (final path in files) {
      expect(_source(path), isNot(contains(oldCopy)), reason: path);
    }

    expect(_source('lib/models/leaderboard.dart'), contains('Bronze Tier'));
    expect(_source('lib/data/achievements.dart'), contains('Weekly Climber'));
    expect(
      _source('lib/services/analytics_service.dart'),
      contains('next weekly tier'),
    );
  });
}
