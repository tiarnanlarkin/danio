// Widget tests for Weekly Plan.
//
// Run: flutter test test/widget_tests/weekly_plan_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/features/smart/weekly_plan/weekly_plan_screen.dart';
import 'package:danio/models/models.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/offline_indicator.dart';

class _FakeWeeklyPlanOpenAIService extends OpenAIService {
  _FakeWeeklyPlanOpenAIService()
    : super(client: MockClient((request) async => http.Response('{}', 200)));

  @override
  Future<bool> isConfiguredAsync() async => true;

  @override
  Future<ChatResult> chatCompletion({
    required List<ChatMessage> messages,
    String model = OpenAIModels.chat,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    return ChatResult(text: jsonEncode(_weeklyPlanJson));
  }
}

const _weeklyPlanJson = {
  'days': [
    {
      'day': 'Mon',
      'tasks': [
        {
          'task': 'Test ammonia and nitrite',
          'duration_mins': 5,
          'priority': 'high',
        },
      ],
    },
    {
      'day': 'Tue',
      'tasks': [
        {'task': 'Feed lightly', 'duration_mins': 3, 'priority': 'normal'},
      ],
    },
    {
      'day': 'Wed',
      'tasks': [
        {'task': 'Check filter flow', 'duration_mins': 4, 'priority': 'normal'},
      ],
    },
    {
      'day': 'Thu',
      'tasks': [
        {
          'task': 'Inspect fish behaviour',
          'duration_mins': 5,
          'priority': 'normal',
        },
      ],
    },
    {
      'day': 'Fri',
      'tasks': [
        {
          'task': 'Top up evaporated water',
          'duration_mins': 5,
          'priority': 'low',
        },
      ],
    },
    {
      'day': 'Sat',
      'tasks': [
        {
          'task': 'Prepare water change kit',
          'duration_mins': 8,
          'priority': 'normal',
        },
      ],
    },
    {
      'day': 'Sun',
      'tasks': [
        {'task': 'Review weekly notes', 'duration_mins': 5, 'priority': 'low'},
      ],
    },
  ],
};

Widget _wrap({required Tank tank}) {
  return ProviderScope(
    overrides: [
      tanksProvider.overrideWith((ref) async => [tank]),
      livestockProvider(tank.id).overrideWith((ref) async => []),
      openAIServiceProvider.overrideWithValue(_FakeWeeklyPlanOpenAIService()),
      openAIConfiguredProvider.overrideWith((ref) async => true),
      isOnlineProvider.overrideWithValue(true),
    ],
    child: const MaterialApp(home: WeeklyPlanScreen()),
  );
}

Tank _tank() {
  final now = DateTime(2026, 6, 24, 10);
  return Tank(
    id: 'weekly-plan-tank',
    name: 'Weekly Plan Tank',
    type: TankType.freshwater,
    volumeLitres: 90,
    startDate: now.subtract(const Duration(days: 90)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'openai_disclosure_accepted': true,
    });
  });

  testWidgets('canceling AI weekly plan confirmation does not cache the plan', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_wrap(tank: _tank()));
    await tester.pumpAndSettle();

    expect(find.text('Save Weekly Plan?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(prefs.getString('weekly_plan_cache'), isNull);
    expect(
      find.text('No plan yet -- tap generate to get started!'),
      findsOneWidget,
    );
  });
}
