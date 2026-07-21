import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/features/smart/fish_id/fish_id_screen.dart';
import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/offline_indicator.dart';

class _FakeFishIdOpenAIService extends OpenAIService {
  _FakeFishIdOpenAIService() : super(directApiKey: 'sk-test');

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
    return const ChatResult(
      text: '''
{
  "common_name": "Neon Tetra",
  "scientific_name": "Paracheirodon innesi",
  "care_level": 1,
  "ph_min": 6.0,
  "ph_max": 7.5,
  "temp_min": 22.0,
  "temp_max": 26.0,
  "hardness": "Soft to moderate",
  "max_size_cm": 4.0,
  "diet": "Omnivore",
  "tank_mates": ["Corydoras"],
  "compatibility_notes": "Keep in a peaceful school.",
  "care_tips": ["Keep at least six together."],
  "is_plant": false,
  "confidence": "high"
}
''',
    );
  }
}

class _RecordingSharedPreferences implements SharedPreferences {
  _RecordingSharedPreferences({
    required SharedPreferences delegate,
    this.failAiHistoryWrite = false,
  }) : _delegate = delegate;

  final SharedPreferences _delegate;
  final bool failAiHistoryWrite;
  int aiHistoryWriteAttempts = 0;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) {
    if (key == 'ai_interaction_history') {
      aiHistoryWriteAttempts += 1;
      if (failAiHistoryWrite) {
        throw StateError('Simulated AI history write failure');
      }
    }
    return _delegate.setStringList(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({
  required SharedPreferences prefs,
  required _FakeFishIdOpenAIService openAI,
  required Future<File?> Function() pickImage,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      openAIServiceProvider.overrideWithValue(openAI),
      isOnlineProvider.overrideWithValue(true),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
    ],
    child: MaterialApp(
      home: FishIdScreen(imagePicker: (_) => pickImage()),
    ),
  );
}

File _createTestImage() {
  final file = File('assets/icons/app_icon.png');
  expect(file.existsSync(), isTrue);
  return file;
}

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  for (var i = 0; i < 100; i += 1) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for "$text".');
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var i = 0; i < 100; i += 1) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
    if (condition()) return;
  }
  fail('Timed out waiting for Fish ID state.');
}

Future<void> _startIdentification({
  required WidgetTester tester,
  required SharedPreferences prefs,
  required _FakeFishIdOpenAIService openAI,
  required File selectedImage,
  void Function()? onPick,
}) async {
  await tester.pumpWidget(
    _wrap(
      prefs: prefs,
      openAI: openAI,
      pickImage: () async {
        onPick?.call();
        return selectedImage;
      },
    ),
  );
  await tester.tap(find.text('Gallery'));
  await _pumpUntilText(tester, 'Neon Tetra');
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'canceling Fish ID activity save keeps result visible and writes nothing',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'openai_disclosure_accepted': true,
      });
      final prefs = _RecordingSharedPreferences(
        delegate: await SharedPreferences.getInstance(),
      );
      final openAI = _FakeFishIdOpenAIService();
      final selectedImage = _createTestImage();
      var pickerCalls = 0;

      await _startIdentification(
        tester: tester,
        prefs: prefs,
        openAI: openAI,
        selectedImage: selectedImage,
        onPick: () => pickerCalls += 1,
      );

      expect(pickerCalls, 1);
      expect(openAI.chatCompletionCalls, 1);
      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(find.text('Save Fish ID Activity?'), findsOneWidget);
      expect(prefs.aiHistoryWriteAttempts, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(prefs.aiHistoryWriteAttempts, 0);
      expect(prefs.getStringList('ai_interaction_history'), isNull);
      expect(find.text('Neon Tetra'), findsOneWidget);
    },
  );

  testWidgets('dismissing Fish ID activity save writes nothing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'openai_disclosure_accepted': true,
    });
    final prefs = _RecordingSharedPreferences(
      delegate: await SharedPreferences.getInstance(),
    );

    await _startIdentification(
      tester: tester,
      prefs: prefs,
      openAI: _FakeFishIdOpenAIService(),
      selectedImage: _createTestImage(),
    );
    expect(find.text('Save Fish ID Activity?'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(prefs.aiHistoryWriteAttempts, 0);
    expect(prefs.getStringList('ai_interaction_history'), isNull);
    expect(find.text('Neon Tetra'), findsOneWidget);
  });

  testWidgets('confirming Fish ID activity save writes exactly once', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'openai_disclosure_accepted': true,
    });
    final prefs = _RecordingSharedPreferences(
      delegate: await SharedPreferences.getInstance(),
    );

    await _startIdentification(
      tester: tester,
      prefs: prefs,
      openAI: _FakeFishIdOpenAIService(),
      selectedImage: _createTestImage(),
    );

    await tester.tap(find.text('Save Activity'));
    await _pumpUntil(tester, () => prefs.aiHistoryWriteAttempts == 1);
    await tester.pumpAndSettle();

    final history = prefs.getStringList('ai_interaction_history') ?? [];
    expect(prefs.aiHistoryWriteAttempts, 1);
    expect(history, hasLength(1));
    expect(history.single, contains('"type":"fish_id"'));
    expect(history.single, contains('Identified: Neon Tetra'));
    expect(find.text('Neon Tetra'), findsOneWidget);
  });

  testWidgets('failed Fish ID history save never hides the visible result', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'openai_disclosure_accepted': true,
    });
    final prefs = _RecordingSharedPreferences(
      delegate: await SharedPreferences.getInstance(),
      failAiHistoryWrite: true,
    );

    await _startIdentification(
      tester: tester,
      prefs: prefs,
      openAI: _FakeFishIdOpenAIService(),
      selectedImage: _createTestImage(),
    );

    await tester.tap(find.text('Save Activity'));
    await _pumpUntil(tester, () => prefs.aiHistoryWriteAttempts == 1);
    await tester.pumpAndSettle();

    expect(prefs.aiHistoryWriteAttempts, 1);
    expect(prefs.getStringList('ai_interaction_history'), isNull);
    expect(find.text('Neon Tetra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
