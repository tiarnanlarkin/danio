// Widget tests for Symptom Triage.
//
// Run: flutter test test/widget_tests/symptom_triage_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/features/smart/ai_disclosure_preferences.dart';
import 'package:danio/features/smart/symptom_triage/symptom_triage_screen.dart';
import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/widgets/core/app_button.dart';
import 'package:danio/widgets/offline_indicator.dart';

class _FakeOpenAIService extends OpenAIService {
  _FakeOpenAIService()
    : super(client: MockClient((request) async => http.Response('{}', 200)));

  int streamCalls = 0;

  @override
  Future<bool> isConfiguredAsync() async => true;

  @override
  Stream<String> chatCompletionStream({
    required List<ChatMessage> messages,
    String model = OpenAIModels.chat,
    double temperature = 0.7,
    int? maxTokens,
  }) async* {
    streamCalls += 1;
    yield 'Likely water quality stress. Test ammonia and nitrite first.';
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
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

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
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

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

class _SymptomTriageStorage implements StorageService {
  _SymptomTriageStorage(this.tank);

  final Tank tank;
  final savedLogs = <LogEntry>[];

  @override
  Future<List<Tank>> getAllTanks() async => [tank];

  @override
  Future<Tank?> getTank(String id) async => id == tank.id ? tank : null;

  @override
  Future<void> saveTank(Tank tank) async {}

  @override
  Future<void> saveTanks(List<Tank> tanks) async {}

  @override
  Future<void> deleteTank(String id) async {}

  @override
  Future<void> deleteAllTanks(List<String> ids) async {}

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async => [];

  @override
  Future<void> saveLivestock(Livestock livestock) async {}

  @override
  Future<void> deleteLivestock(String id) async {}

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async => [];

  @override
  Future<void> saveEquipment(Equipment equipment) async {}

  @override
  Future<void> deleteEquipment(String id) async {}

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async => savedLogs.where((log) => log.tankId == tankId).toList();

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) async => null;

  @override
  Future<void> saveLog(LogEntry log) async {
    savedLogs.add(log);
  }

  @override
  Future<void> deleteLog(String id) async {}

  @override
  Future<List<Task>> getTasksForTank(String? tankId) async => [];

  @override
  Future<void> saveTask(Task task) async {}

  @override
  Future<void> deleteTask(String id) async {}
}

Widget _wrap({
  required _SymptomTriageStorage storage,
  SharedPreferences? prefs,
  _FakeOpenAIService? openAI,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      storageServiceProvider.overrideWithValue(storage),
      tanksProvider.overrideWith((ref) async => [storage.tank]),
      openAIServiceProvider.overrideWithValue(openAI ?? _FakeOpenAIService()),
      openAIConfiguredProvider.overrideWith((ref) async => true),
      isOnlineProvider.overrideWithValue(true),
    ],
    child: const MaterialApp(home: SymptomTriageScreen()),
  );
}

Tank _tank() {
  final now = DateTime(2026, 6, 24, 10);
  return Tank(
    id: 'triage-tank',
    name: 'Triage Tank',
    type: TankType.freshwater,
    volumeLitres: 90,
    startDate: now.subtract(const Duration(days: 90)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _startDiagnosisFromFirstStep(WidgetTester tester) async {
  await tester.tap(find.text('White spots'));
  await tester.pump();

  await tester.tap(find.widgetWithText(AppButton, 'Next').hitTestable());
  await tester.pumpAndSettle();

  await tester.tap(
    find.widgetWithText(AppButton, 'Get Diagnosis').hitTestable(),
  );
  await tester.pumpAndSettle();
}

Future<void> _generateDiagnosis(WidgetTester tester) async {
  await _startDiagnosisFromFirstStep(tester);

  expect(
    find.text('Likely water quality stress. Test ammonia and nitrite first.'),
    findsOneWidget,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'openai_disclosure_accepted': true,
    });
  });

  testWidgets('canceling AI journal save confirmation does not write a log', (
    tester,
  ) async {
    final storage = _SymptomTriageStorage(_tank());

    await tester.pumpWidget(_wrap(storage: storage));
    await tester.pump();

    await _generateDiagnosis(tester);

    await tester.tap(
      find.widgetWithText(AppButton, 'Save to Journal').hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Save AI Diagnosis?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(storage.savedLogs, isEmpty);
    expect(find.byType(SymptomTriageScreen), findsOneWidget);
  });

  testWidgets('failed disclosure save does not request diagnosis', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final failingPrefs = _FalseSetBoolPrefs(
      prefs,
      AiDisclosurePreferences.acceptedKey,
    );
    final storage = _SymptomTriageStorage(_tank());
    final openAI = _FakeOpenAIService();

    await tester.pumpWidget(
      _wrap(storage: storage, prefs: failingPrefs, openAI: openAI),
    );
    await tester.pump();

    await _startDiagnosisFromFirstStep(tester);

    expect(find.text('OpenAI Data Disclosure'), findsOneWidget);

    await tester.tap(find.text('I Understand'));
    await tester.pumpAndSettle();

    expect(openAI.streamCalls, 0);
    expect(prefs.getBool(AiDisclosurePreferences.acceptedKey), isNull);
    expect(
      find.text('Couldn\'t save AI disclosure. Try again.'),
      findsOneWidget,
    );
  });
}
