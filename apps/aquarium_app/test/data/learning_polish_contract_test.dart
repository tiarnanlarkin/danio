import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/theme/learning_visuals.dart';

void main() {
  group('Learning polish contracts', () {
    test('every learning path has a polished visual mapping', () {
      for (final metadata in LessonProvider.allPathMetadata) {
        expect(
          LearningVisuals.hasPathVisual(metadata.id),
          isTrue,
          reason: 'Missing LearningVisuals mapping for ${metadata.id}',
        );
      }
    });

    test('nitrogen cycle uses the tank waste-flow visual asset', () {
      final visual = LearningVisuals.forPath('nitrogen_cycle');

      expect(
        visual.assetPath,
        'assets/images/illustrations/nitrogen_cycle_flow.png',
      );
      expect(File(visual.assetPath!).existsSync(), isTrue);
    });

    test('polished learning surfaces do not render raw emoji strings', () {
      final targets = [
        Directory('lib/screens/learn'),
        Directory('lib/screens/lesson'),
        Directory('lib/screens/spaced_repetition_practice'),
        File('lib/screens/practice_hub_screen.dart'),
        File('lib/providers/achievement_provider.dart'),
        File('lib/widgets/learning_streak_badge.dart'),
        File('lib/widgets/hearts_widgets.dart'),
        File('lib/widgets/lesson_celebration_overlay.dart'),
        File('lib/widgets/celebrations/level_up_overlay.dart'),
        File('lib/widgets/level_up_dialog.dart'),
        File('lib/widgets/achievement_unlocked_dialog.dart'),
      ];

      final files = targets.expand<File>((target) {
        if (target is File) return [target];
        final directory = target as Directory;
        return directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'));
      });

      final rawEmoji = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
        unicode: true,
      );
      final escapedEmoji = RegExp(
        r'\\u2b50|\\ud83d|\\u\{1F|\\u\{260|\\u\{2728',
        caseSensitive: false,
      );

      final failures = <String>[];
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (rawEmoji.hasMatch(line) || escapedEmoji.hasMatch(line)) {
            failures.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }

      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  });
}
