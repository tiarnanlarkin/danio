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

import 'package:danio/features/smart/ai_disclosure_preferences.dart';
import 'package:danio/features/smart/weekly_plan/weekly_plan_screen.dart';
import 'package:danio/models/models.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/offline_indicator.dart';

class _FakeWeeklyPlanOpenAIService extends OpenAIService {
  _FakeWeeklyPlanOpenAIService()
    : super(client: MockClient((request) async => http.Response('{}', 200)));

  int chatCompletionCalls = 0;

  @override
  Future<bool> isConfiguredAsync() async => true;

  @override
  Future<ChatResult> chatCompletion({
    required List<ChatMessage> messages,
    String model = OpenAIModels.chat,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    chatCompletionCalls += 1;
    return ChatResult(text: jsonEncode(_weeklyPlanJson));
  }
}

class _FalseSetBoolPrefs implements SharedPreferences {
  _FalseSetBoolPrefs(this._delegate, this._failedKey);

  final SharedPreferences _delegate;
  final String _failedKey;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (key == _failedKey) return false;
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> setString(String key, String value) {
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    return _delegate.setStringList(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

Widget _wrap({
  required Tank tank,
  SharedPreferences? prefs,
  _FakeWeeklyPlanOpenAIService? openAI,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      tanksProvider.overrideWith((ref) async => [tank]),
      livestockProvider(tank.id).overrideWith((ref) async => []),
      openAIServiceProvider.overrideWithValue(
        openAI ?? _FakeWeeklyPlanOpenAIService(),
      ),
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

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  for (var i = 0; i < 30; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  expect(find.text(text), findsOneWidget);
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
    await _pumpUntilText(tester, 'Save Weekly Plan?');

    expect(find.text('Save Weekly Plan?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await _pumpUntilText(tester, 'No plan yet -- tap generate to get started!');

    expect(prefs.getString('weekly_plan_cache'), isNull);
    expect(
      find.text('No plan yet -- tap generate to get started!'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('failed disclosure save does not request or cache a plan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final failingPrefs = _FalseSetBoolPrefs(
      prefs,
      AiDisclosurePreferences.acceptedKey,
    );
    final openAI = _FakeWeeklyPlanOpenAIService();

    await tester.pumpWidget(
      _wrap(tank: _tank(), prefs: failingPrefs, openAI: openAI),
    );
    await _pumpUntilText(tester, 'OpenAI Data Disclosure');

    expect(find.text('OpenAI Data Disclosure'), findsOneWidget);

    await tester.tap(find.text('I Understand'));
    await _pumpUntilText(tester, 'Couldn\'t save AI disclosure. Try again.');

    expect(openAI.chatCompletionCalls, 0);
    expect(prefs.getBool(AiDisclosurePreferences.acceptedKey), isNull);
    expect(prefs.getString('weekly_plan_cache'), isNull);
    expect(
      find.text('Couldn\'t save AI disclosure. Try again.'),
      findsOneWidget,
    );
  });
}
