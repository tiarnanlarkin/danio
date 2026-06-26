// Persistence tests for Smart provider local caches.
//
// Run: flutter test test/providers/smart_provider_persistence_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/features/smart/models/smart_models.dart';
import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/providers/user_profile_provider.dart';

class _DelayedSmartPrefs implements SharedPreferences {
  _DelayedSmartPrefs({
    required SharedPreferences delegate,
    required this.delayedKey,
    required this.gate,
  }) : _delegate = delegate;

  final SharedPreferences _delegate;
  final String delayedKey;
  final Completer<bool> gate;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Future<bool> setString(String key, String value) {
    if (key == delayedKey) {
      return gate.future.then((saved) async {
        if (!saved) return false;
        return _delegate.setString(key, value);
      });
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    if (key == delayedKey) {
      return gate.future.then((saved) async {
        if (!saved) return false;
        return _delegate.setStringList(key, value);
      });
    }
    return _delegate.setStringList(key, value);
  }

  @override
  Future<bool> remove(String key) {
    if (key == delayedKey) {
      return gate.future.then((removed) async {
        if (!removed) return false;
        return _delegate.remove(key);
      });
    }
    return _delegate.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForAiHistoryLoad(
  ProviderContainer container, {
  int expectedLength = 0,
}) async {
  for (var i = 0; i < 20; i += 1) {
    if (container.read(aiHistoryProvider).length == expectedLength) return;
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForAnomalyHistoryLoad(
  ProviderContainer container, {
  int expectedLength = 0,
}) async {
  for (var i = 0; i < 20; i += 1) {
    if (container.read(anomalyHistoryProvider).length == expectedLength) return;
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitForWeeklyPlanLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    if (container.read(weeklyPlanProvider) != null) return;
    await Future<void>.delayed(Duration.zero);
  }
}

WeeklyPlan _weeklyPlan() {
  return WeeklyPlan(
    generatedAt: DateTime(2026, 6, 23, 10),
    days: const [
      PlanDay(
        day: 'Mon',
        tasks: [
          PlanTask(
            task: 'Test ammonia and nitrite',
            durationMins: 5,
            priority: 'high',
          ),
        ],
      ),
    ],
  );
}

Anomaly _anomaly({bool dismissed = false}) {
  return Anomaly(
    id: 'ammonia-spike',
    tankId: 'tank-1',
    parameter: 'ammonia',
    description: 'Ammonia is above safe freshwater range.',
    severity: AnomalySeverity.critical,
    detectedAt: DateTime(2026, 6, 23, 9),
    dismissed: dismissed,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smart provider persistence', () {
    test(
      'AI history waits for local save before exposing interaction',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSmartPrefs(
                delegate: prefs,
                delayedKey: 'ai_interaction_history',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(aiHistoryProvider, (_, __) {});
        addTearDown(subscription.close);
        await _waitForAiHistoryLoad(container);

        final save = container
            .read(aiHistoryProvider.notifier)
            .add(
              type: 'ask_danio',
              summary: 'Asked about ammonia',
            );
        await Future<void>.delayed(Duration.zero);

        expect(container.read(aiHistoryProvider), isEmpty);

        saveGate.complete(true);
        await save;

        expect(container.read(aiHistoryProvider), hasLength(1));
        expect(prefs.getStringList('ai_interaction_history'), hasLength(1));
      },
    );

    test('weekly plan waits for cache save before exposing plan', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSmartPrefs(
              delegate: prefs,
              delayedKey: 'weekly_plan_cache',
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(weeklyPlanProvider, (_, __) {});
      addTearDown(subscription.close);
      final plan = _weeklyPlan();

      final save = container.read(weeklyPlanProvider.notifier).save(plan);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(weeklyPlanProvider), isNull);

      saveGate.complete(true);
      await save;

      expect(container.read(weeklyPlanProvider), same(plan));
      expect(
        jsonDecode(prefs.getString('weekly_plan_cache')!)
            as Map<String, dynamic>,
        containsPair('generated_at', '2026-06-23T10:00:00.000'),
      );
    });

    test(
      'weekly plan surfaces cache write failures without exposing plan',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final saveGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSmartPrefs(
                delegate: prefs,
                delayedKey: 'weekly_plan_cache',
                gate: saveGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(weeklyPlanProvider, (_, __) {});
        addTearDown(subscription.close);

        final save = container
            .read(weeklyPlanProvider.notifier)
            .save(_weeklyPlan());
        await Future<void>.delayed(Duration.zero);
        saveGate.complete(false);

        await expectLater(save, throwsA(isA<StateError>()));
        expect(container.read(weeklyPlanProvider), isNull);
        expect(prefs.getString('weekly_plan_cache'), isNull);
      },
    );

    test(
      'weekly plan clear waits for cache removal before hiding plan',
      () async {
        final plan = _weeklyPlan();
        SharedPreferences.setMockInitialValues({
          'weekly_plan_cache': jsonEncode(plan.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final removeGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSmartPrefs(
                delegate: prefs,
                delayedKey: 'weekly_plan_cache',
                gate: removeGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(weeklyPlanProvider, (_, __) {});
        addTearDown(subscription.close);
        await _waitForWeeklyPlanLoad(container);

        final clear = container.read(weeklyPlanProvider.notifier).clear();
        await Future<void>.delayed(Duration.zero);

        expect(container.read(weeklyPlanProvider), isNotNull);
        expect(prefs.getString('weekly_plan_cache'), isNotNull);

        removeGate.complete(true);
        await clear;

        expect(container.read(weeklyPlanProvider), isNull);
        expect(prefs.getString('weekly_plan_cache'), isNull);
      },
    );

    test(
      'weekly plan clear surfaces cache removal failures without hiding plan',
      () async {
        final plan = _weeklyPlan();
        SharedPreferences.setMockInitialValues({
          'weekly_plan_cache': jsonEncode(plan.toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final removeGate = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async {
              return _DelayedSmartPrefs(
                delegate: prefs,
                delayedKey: 'weekly_plan_cache',
                gate: removeGate,
              );
            }),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(weeklyPlanProvider, (_, __) {});
        addTearDown(subscription.close);
        await _waitForWeeklyPlanLoad(container);

        final clear = container.read(weeklyPlanProvider.notifier).clear();
        await Future<void>.delayed(Duration.zero);
        removeGate.complete(false);

        await expectLater(clear, throwsA(isA<StateError>()));
        expect(container.read(weeklyPlanProvider), isNotNull);
        expect(prefs.getString('weekly_plan_cache'), isNotNull);
      },
    );

    test('anomaly add waits for local save before exposing alerts', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSmartPrefs(
              delegate: prefs,
              delayedKey: 'anomaly_history',
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(anomalyHistoryProvider, (_, __) {});
      addTearDown(subscription.close);
      await _waitForAnomalyHistoryLoad(container);

      final save = container.read(anomalyHistoryProvider.notifier).addAll([
        _anomaly(),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(anomalyHistoryProvider), isEmpty);

      saveGate.complete(true);
      await save;

      expect(container.read(anomalyHistoryProvider), hasLength(1));
      expect(prefs.getStringList('anomaly_history'), hasLength(1));
    });

    test('anomaly dismiss waits for local save before hiding alert', () async {
      final anomaly = _anomaly();
      SharedPreferences.setMockInitialValues({
        'anomaly_history': [jsonEncode(anomaly.toJson())],
      });
      final prefs = await SharedPreferences.getInstance();
      final saveGate = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _DelayedSmartPrefs(
              delegate: prefs,
              delayedKey: 'anomaly_history',
              gate: saveGate,
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(anomalyHistoryProvider, (_, __) {});
      addTearDown(subscription.close);
      await _waitForAnomalyHistoryLoad(container, expectedLength: 1);

      final save = container
          .read(anomalyHistoryProvider.notifier)
          .dismiss(anomaly.id);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(anomalyHistoryProvider).single.dismissed, isFalse);

      saveGate.complete(true);
      await save;

      expect(container.read(anomalyHistoryProvider).single.dismissed, isTrue);
    });
  });
}
