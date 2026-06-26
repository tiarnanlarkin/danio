import 'package:danio/data/care_sources.dart';
import 'package:danio/data/lessons/advanced_topics.dart';
import 'package:danio/data/lessons/aquascaping.dart';
import 'package:danio/data/lessons/breeding.dart';
import 'package:danio/data/lessons/equipment.dart';
import 'package:danio/data/lessons/equipment_expanded.dart';
import 'package:danio/data/lessons/first_fish.dart';
import 'package:danio/data/lessons/fish_health.dart';
import 'package:danio/data/lessons/maintenance.dart';
import 'package:danio/data/lessons/nitrogen_cycle.dart';
import 'package:danio/data/lessons/planted_tank.dart';
import 'package:danio/data/lessons/species_care.dart';
import 'package:danio/data/lessons/species_care_expanded.dart';
import 'package:danio/data/lessons/troubleshooting.dart';
import 'package:danio/data/lessons/water_parameters.dart';
import 'package:danio/data/plant_database.dart';
import 'package:danio/data/species_database.dart';
import 'package:danio/models/learning.dart';
import 'package:flutter_test/flutter_test.dart';

LearningPath get _mergedEquipmentPath => LearningPath(
  id: equipmentPath.id,
  title: equipmentPath.title,
  description: equipmentPath.description,
  emoji: equipmentPath.emoji,
  recommendedFor: equipmentPath.recommendedFor,
  orderIndex: equipmentPath.orderIndex,
  lessons: [...equipmentPath.lessons, ...equipmentExpandedLessons],
);

LearningPath get _mergedSpeciesCarePath => LearningPath(
  id: speciesCarePath.id,
  title: speciesCarePath.title,
  description: speciesCarePath.description,
  emoji: speciesCarePath.emoji,
  recommendedFor: speciesCarePath.recommendedFor,
  orderIndex: speciesCarePath.orderIndex,
  lessons: [...speciesCarePath.lessons, ...speciesCareExpandedLessons],
);

List<LearningPath> get _allPaths => [
  nitrogenCyclePath,
  waterParametersPath,
  firstFishPath,
  maintenancePath,
  plantedTankPath,
  _mergedEquipmentPath,
  fishHealthPath,
  _mergedSpeciesCarePath,
  advancedTopicsPath,
  aquascapingPath,
  breedingBasicsPath,
  troubleshootingPath,
];

List<Lesson> get _allLessons =>
    _allPaths.expand((path) => path.lessons).toList();

const _bannedProductionCopy = [
  'coming soon',
  'lorem ipsum',
  'todo:',
  'tbd',
  'dummy content',
  'fake premium',
  'fake social',
  'fake cloud',
  'subscribe to unlock',
];

String _normalise(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

Iterable<MapEntry<String, String>> _lessonStrings(Lesson lesson) sync* {
  yield MapEntry('lesson ${lesson.id} title', lesson.title);
  yield MapEntry('lesson ${lesson.id} description', lesson.description);

  for (var index = 0; index < lesson.sections.length; index++) {
    final section = lesson.sections[index];
    yield MapEntry('lesson ${lesson.id} section $index', section.content);
    final caption = section.caption;
    if (caption != null) {
      yield MapEntry('lesson ${lesson.id} section $index caption', caption);
    }
  }

  final guide = lesson.guide;
  if (guide != null) {
    for (var index = 0; index < guide.outcomes.length; index++) {
      yield MapEntry(
        'lesson ${lesson.id} outcome $index',
        guide.outcomes[index],
      );
    }
    yield MapEntry('lesson ${lesson.id} scenario', guide.scenario);
    for (var index = 0; index < guide.careDrill.length; index++) {
      yield MapEntry(
        'lesson ${lesson.id} care drill $index',
        guide.careDrill[index],
      );
    }
    for (final source in guide.sources) {
      yield MapEntry('lesson ${lesson.id} source title', source.title);
      yield MapEntry('lesson ${lesson.id} source publisher', source.publisher);
      yield MapEntry('lesson ${lesson.id} source note', source.note);
    }
  }

  final quiz = lesson.quiz;
  if (quiz != null) {
    for (final question in quiz.questions) {
      yield MapEntry('question ${question.id}', question.question);
      for (var index = 0; index < question.options.length; index++) {
        yield MapEntry(
          'question ${question.id} option $index',
          question.options[index],
        );
      }
      final explanation = question.explanation;
      if (explanation != null) {
        yield MapEntry('question ${question.id} explanation', explanation);
      }
    }
  }
}

Iterable<MapEntry<String, String>> _speciesStrings(SpeciesInfo species) sync* {
  yield MapEntry('${species.commonName} common name', species.commonName);
  yield MapEntry(
    '${species.commonName} scientific name',
    species.scientificName,
  );
  yield MapEntry('${species.commonName} family', species.family);
  yield MapEntry('${species.commonName} diet', species.diet);
  yield MapEntry('${species.commonName} description', species.description);
  for (final item in species.compatibleWith) {
    yield MapEntry('${species.commonName} compatible species', item);
  }
  for (final item in species.avoidWith) {
    yield MapEntry('${species.commonName} avoid species', item);
  }
  for (final warning in species.medicationWarnings) {
    yield MapEntry('${species.commonName} medication warning', warning);
  }
}

Iterable<MapEntry<String, String>> _plantStrings(PlantInfo plant) sync* {
  yield MapEntry('${plant.commonName} common name', plant.commonName);
  yield MapEntry('${plant.commonName} scientific name', plant.scientificName);
  yield MapEntry('${plant.commonName} family', plant.family);
  yield MapEntry('${plant.commonName} origin', plant.origin);
  yield MapEntry('${plant.commonName} propagation', plant.propagation);
  yield MapEntry('${plant.commonName} description', plant.description);
  for (final tip in plant.tips) {
    yield MapEntry('${plant.commonName} tip', tip);
  }
}

String _lessonSearchText(Lesson lesson) {
  final buffer = StringBuffer()
    ..write(lesson.id)
    ..write(' ')
    ..write(lesson.title)
    ..write(' ')
    ..write(lesson.description);

  for (final entry in _lessonStrings(lesson)) {
    buffer
      ..write(' ')
      ..write(entry.value);
  }

  return _normalise(buffer.toString());
}

void _expectNoBannedCopy(Iterable<MapEntry<String, String>> entries) {
  for (final entry in entries) {
    final value = _normalise(entry.value);
    for (final banned in _bannedProductionCopy) {
      expect(
        value,
        isNot(contains(banned)),
        reason: '${entry.key} contains banned draft/product copy: $banned',
      );
    }
  }
}

void _expectHttpsSource({
  required String title,
  required String publisher,
  required String url,
  required String note,
}) {
  expect(title.trim(), isNotEmpty, reason: 'Source title is empty');
  expect(publisher.trim(), isNotEmpty, reason: 'Source publisher is empty');
  expect(note.trim(), isNotEmpty, reason: 'Source note is empty');

  final uri = Uri.tryParse(url);
  expect(uri, isNotNull, reason: 'Source URL is not parseable: $url');
  expect(
    uri?.scheme,
    equals('https'),
    reason: 'Source URL must use https: $url',
  );
  expect(uri?.host, isNotEmpty, reason: 'Source URL has no host: $url');
}

void main() {
  group('content validation gate', () {
    test(
      'learning content avoids draft placeholders and fake feature copy',
      () {
        _expectNoBannedCopy(_allLessons.expand(_lessonStrings));
      },
    );

    test(
      'lesson quizzes are complete, explain answers, and avoid duplicate options',
      () {
        final quizIds = <String>{};
        final questionIds = <String>{};

        for (final lesson in _allLessons) {
          final quiz = lesson.quiz;
          expect(quiz, isNotNull, reason: 'Lesson ${lesson.id} has no quiz');
          expect(
            quiz!.lessonId,
            equals(lesson.id),
            reason: 'Quiz ${quiz.id} points at the wrong lesson',
          );
          expect(
            quizIds.add(quiz.id),
            isTrue,
            reason: 'Duplicate quiz ID: ${quiz.id}',
          );
          expect(
            quiz.questions.length,
            greaterThanOrEqualTo(1),
            reason: 'Lesson ${lesson.id} needs at least one quiz question',
          );
          expect(quiz.passingScore, inInclusiveRange(50, 100));
          expect(quiz.bonusXp, greaterThanOrEqualTo(0));

          for (final question in quiz.questions) {
            expect(
              questionIds.add(question.id),
              isTrue,
              reason: 'Duplicate quiz question ID: ${question.id}',
            );
            expect(
              question.explanation?.trim().length ?? 0,
              greaterThanOrEqualTo(20),
              reason:
                  'Question ${question.id} needs an explanatory answer note',
            );

            final normalisedOptions = question.options.map(_normalise).toSet();
            expect(
              normalisedOptions.length,
              equals(question.options.length),
              reason: 'Question ${question.id} has duplicate answer options',
            );
          }
        }
      },
    );

    test('lesson and care sources are traceable https references', () {
      final sourceKeys = <String>{};

      for (final lesson in _allLessons) {
        for (final source in lesson.guide!.sources) {
          _expectHttpsSource(
            title: source.title,
            publisher: source.publisher,
            url: source.url,
            note: source.note,
          );
          sourceKeys.add('${source.publisher}|${source.url}');
        }
      }

      for (final source in [...fishCareSources, ...plantCareSources]) {
        _expectHttpsSource(
          title: source.title,
          publisher: source.publisher,
          url: source.url,
          note: source.note,
        );
        sourceKeys.add('${source.publisher}|${source.url}');
      }

      expect(
        sourceKeys.length,
        greaterThanOrEqualTo(10),
        reason: 'Content should cite a broad set of care references',
      );
    });

    test(
      'emergency lessons keep a clear professional escalation boundary',
      () {
        final emergencyLessons = _allLessons.where((lesson) {
          final keyText = _normalise(
            '${lesson.id} ${lesson.title} ${lesson.description}',
          );
          return keyText.contains('emergency') || keyText.contains('distress');
        }).toList();

        expect(
          emergencyLessons,
          isNotEmpty,
          reason: 'Expected at least one emergency lesson in the catalog',
        );

        for (final lesson in emergencyLessons) {
          final text = _lessonSearchText(lesson);
          expect(
            text,
            anyOf(contains('aquatic vet'), contains('veterinarian')),
            reason:
                'Emergency lesson ${lesson.id} must tell users when to seek professional help',
          );
          expect(
            text,
            contains('educational'),
            reason:
                'Emergency lesson ${lesson.id} must keep Danio positioned as educational guidance',
          );
        }
      },
    );

    test('emergency lessons are not locked behind prerequisites', () {
      final emergencyLessons = _allLessons.where((lesson) {
        final keyText = _normalise(
          '${lesson.id} ${lesson.title} ${lesson.description}',
        );
        return keyText.contains('emergency') || keyText.contains('distress');
      }).toList();

      expect(
        emergencyLessons,
        isNotEmpty,
        reason: 'Expected at least one emergency lesson in the catalog',
      );

      for (final lesson in emergencyLessons) {
        expect(
          lesson.prerequisites,
          isEmpty,
          reason: 'Emergency lesson ${lesson.id} must stay directly accessible',
        );
      }
    });

    test('species database is broad, unique, and has sane care ranges', () {
      final species = SpeciesDatabase.species;
      final commonNames = <String>{};
      const careLevels = {'Beginner', 'Intermediate', 'Advanced'};
      const swimLevels = {'Top', 'Middle', 'Bottom', 'All'};
      const temperamentWords = {'Peaceful', 'Semi-aggressive', 'Aggressive'};

      expect(species.length, greaterThanOrEqualTo(75));

      for (final fish in species) {
        _expectNoBannedCopy(_speciesStrings(fish));

        expect(commonNames.add(_normalise(fish.commonName)), isTrue);
        expect(fish.scientificName.trim(), isNotEmpty);
        expect(careLevels, contains(fish.careLevel));
        expect(swimLevels, contains(fish.swimLevel));
        expect(
          temperamentWords.any(fish.temperament.contains),
          isTrue,
          reason:
              '${fish.commonName} has unknown temperament ${fish.temperament}',
        );
        expect(fish.minTankLitres, greaterThan(0));
        expect(fish.minTempC, lessThanOrEqualTo(fish.maxTempC));
        expect(fish.minTempC, inInclusiveRange(0, 35));
        expect(fish.maxTempC, inInclusiveRange(5, 35));
        expect(fish.minPh, lessThanOrEqualTo(fish.maxPh));
        expect(fish.minPh, inInclusiveRange(3.0, 9.5));
        expect(fish.maxPh, inInclusiveRange(3.0, 9.5));
        expect(fish.minSchoolSize, greaterThan(0));
        expect(fish.adultSizeCm, greaterThan(0));

        final minGh = fish.minGh;
        final maxGh = fish.maxGh;
        if (minGh != null && maxGh != null) {
          expect(minGh, lessThanOrEqualTo(maxGh));
          expect(minGh, greaterThanOrEqualTo(0));
          expect(maxGh, lessThanOrEqualTo(40));
        }

        final compatible = fish.compatibleWith.map(_normalise).toSet();
        final avoid = fish.avoidWith.map(_normalise).toSet();
        expect(
          compatible.intersection(avoid),
          isEmpty,
          reason:
              '${fish.commonName} has overlap between compatible and avoid lists',
        );
      }
    });

    test(
      'plant database is broad, unique, and has sane horticulture ranges',
      () {
        final plants = PlantDatabase.plants;
        final commonNames = <String>{};
        final scientificNames = <String>{};
        const difficulties = {'Easy', 'Medium', 'Hard', 'Medium-Hard'};
        const growthRates = {
          'Very Slow',
          'Slow',
          'Medium',
          'Fast',
          'Very Fast',
        };
        const lightLevels = {
          'Low',
          'Medium',
          'High',
          'Low-Medium',
          'Medium-High',
        };
        const placementParts = {
          'Foreground',
          'Midground',
          'Background',
          'Floating',
        };

        expect(plants.length, greaterThanOrEqualTo(40));

        for (final plant in plants) {
          _expectNoBannedCopy(_plantStrings(plant));

          expect(commonNames.add(_normalise(plant.commonName)), isTrue);
          expect(scientificNames.add(_normalise(plant.scientificName)), isTrue);
          expect(difficulties, contains(plant.difficulty));
          expect(growthRates, contains(plant.growthRate));
          expect(lightLevels, contains(plant.lightLevel));
          expect(plant.minHeightCm, greaterThanOrEqualTo(0));
          expect(plant.maxHeightCm, greaterThanOrEqualTo(plant.minHeightCm));
          expect(plant.maxHeightCm, lessThanOrEqualTo(350));
          expect(plant.tips.length, greaterThanOrEqualTo(3));

          for (final placement in plant.placement.split('/')) {
            expect(
              placementParts,
              contains(placement),
              reason:
                  '${plant.commonName} has unknown placement ${plant.placement}',
            );
          }
        }
      },
    );
  });
}
