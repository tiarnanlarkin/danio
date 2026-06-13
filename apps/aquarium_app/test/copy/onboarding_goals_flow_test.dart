import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding captures explicit goals after tank status', () {
    final source = File(
      'lib/screens/onboarding_screen.dart',
    ).readAsStringSync();

    expect(source, contains("import 'onboarding/goals_screen.dart';"));
    expect(
      source.indexOf('GoalsScreen('),
      greaterThan(source.indexOf('TankStatusScreen(')),
    );
    expect(
      source.indexOf('GoalsScreen('),
      lessThan(source.indexOf('MicroLessonScreen(')),
    );
    expect(source, contains('List<UserGoal> _selectedGoals = const [];'));
    expect(source, contains('List<UserGoal> _effectiveGoals()'));
    expect(source, contains('goals: _effectiveGoals()'));
    expect(source, isNot(contains('goals: [_deriveGoal()]')));
  });
}
