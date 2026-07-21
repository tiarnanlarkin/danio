import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/compatibility_checker_widget.dart';
import 'package:danio/widgets/offline_indicator.dart';

const _compatibilityResult = '''
Compatible
- Peaceful community species.
- Water parameters overlap.
Keep a school of at least six.
''';

class _FakeCompatibilityOpenAIService extends OpenAIService {
  _FakeCompatibilityOpenAIService() : super(directApiKey: 'sk-test');

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
    return const ChatResult(text: _compatibilityResult);
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

final _tank = Tank(
  id: 'tank-1',
  name: 'Community Tank',
  type: TankType.freshwater,
  volumeLitres: 120,
  startDate: DateTime(2026, 1, 1),
  targets: WaterTargets.freshwaterTropical(),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Widget _wrap({
  SharedPreferences? prefs,
  _FakeCompatibilityOpenAIService? openAI,
  bool withTank = false,
}) {
  return ProviderScope(
    overrides: [
      tanksProvider.overrideWith((ref) async => withTank ? [_tank] : []),
      if (withTank) ...[
        tankProvider.overrideWith(
          (ref, id) => id == _tank.id ? _tank : null,
        ),
        livestockProvider.overrideWith((ref, id) => []),
      ],
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      openAIServiceProvider.overrideWithValue(
        openAI ?? OpenAIService(directApiKey: ''),
      ),
      openAIConfiguredProvider.overrideWith((ref) async => openAI != null),
      isOnlineProvider.overrideWithValue(true),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CompatibilityCheckerWidget()),
    ),
  );
}

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  for (var i = 0; i < 100; i += 1) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  final visibleText = <String?>[
    ...tester
        .widgetList<Text>(find.byType(Text, skipOffstage: false))
        .map((widget) => widget.data),
    ...tester
        .widgetList<SelectableText>(
          find.byType(SelectableText, skipOffstage: false),
        )
        .map((widget) => widget.data),
  ].whereType<String>().toList();
  fail('Timed out waiting for "$text". Visible text: $visibleText');
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
  fail('Timed out waiting for Compatibility state.');
}

Future<void> _startCompatibilityCheck({
  required WidgetTester tester,
  required _RecordingSharedPreferences prefs,
  required _FakeCompatibilityOpenAIService openAI,
}) async {
  await tester.pumpWidget(
    _wrap(prefs: prefs, openAI: openAI, withTank: true),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Neon Tetra');
  await tester.tap(find.byTooltip('Check compatibility'));
  await _pumpUntilText(tester, _compatibilityResult);
  expect(prefs.aiHistoryWriteAttempts, 0);
  await _pumpUntilText(tester, 'Save Compatibility Activity?');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompatibilityCheckerWidget', () {
    testWidgets('empty submit has clear action label and inline feedback', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Check compatibility'), findsOneWidget);

      await tester.tap(find.byTooltip('Check compatibility'));
      await tester.pump();

      expect(find.text('Enter a species to check first.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
      'canceling Compatibility activity save keeps result visible and writes nothing',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'openai_disclosure_accepted': true,
        });
        final prefs = _RecordingSharedPreferences(
          delegate: await SharedPreferences.getInstance(),
        );
        final openAI = _FakeCompatibilityOpenAIService();

        await _startCompatibilityCheck(
          tester: tester,
          prefs: prefs,
          openAI: openAI,
        );

        expect(openAI.chatCompletionCalls, 1);
        expect(find.text(_compatibilityResult), findsOneWidget);
        expect(find.text('Save Compatibility Activity?'), findsOneWidget);
        expect(prefs.aiHistoryWriteAttempts, 0);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(prefs.aiHistoryWriteAttempts, 0);
        expect(prefs.getStringList('ai_interaction_history'), isNull);
        expect(find.text(_compatibilityResult), findsOneWidget);
      },
    );

    testWidgets('dismissing Compatibility activity save writes nothing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'openai_disclosure_accepted': true,
      });
      final prefs = _RecordingSharedPreferences(
        delegate: await SharedPreferences.getInstance(),
      );

      await _startCompatibilityCheck(
        tester: tester,
        prefs: prefs,
        openAI: _FakeCompatibilityOpenAIService(),
      );
      expect(find.text(_compatibilityResult), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(prefs.aiHistoryWriteAttempts, 0);
      expect(prefs.getStringList('ai_interaction_history'), isNull);
      expect(find.text(_compatibilityResult), findsOneWidget);
    });

    testWidgets('confirming Compatibility activity save writes exactly once', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'openai_disclosure_accepted': true,
      });
      final prefs = _RecordingSharedPreferences(
        delegate: await SharedPreferences.getInstance(),
      );

      await _startCompatibilityCheck(
        tester: tester,
        prefs: prefs,
        openAI: _FakeCompatibilityOpenAIService(),
      );

      await tester.tap(find.text('Save Activity'));
      await _pumpUntil(tester, () => prefs.aiHistoryWriteAttempts == 1);
      await tester.pumpAndSettle();

      final history = prefs.getStringList('ai_interaction_history') ?? [];
      expect(prefs.aiHistoryWriteAttempts, 1);
      expect(history, hasLength(1));
      expect(history.single, contains('"type":"compatibility_check"'));
      expect(history.single, contains('Checked: Neon Tetra in Community Tank'));
      expect(find.text(_compatibilityResult), findsOneWidget);
    });

    testWidgets(
      'failed Compatibility history save never hides the visible result',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'openai_disclosure_accepted': true,
        });
        final prefs = _RecordingSharedPreferences(
          delegate: await SharedPreferences.getInstance(),
          failAiHistoryWrite: true,
        );

        await _startCompatibilityCheck(
          tester: tester,
          prefs: prefs,
          openAI: _FakeCompatibilityOpenAIService(),
        );

        await tester.tap(find.text('Save Activity'));
        await _pumpUntil(tester, () => prefs.aiHistoryWriteAttempts == 1);
        await tester.pumpAndSettle();

        expect(prefs.aiHistoryWriteAttempts, 1);
        expect(prefs.getStringList('ai_interaction_history'), isNull);
        expect(find.text(_compatibilityResult), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
