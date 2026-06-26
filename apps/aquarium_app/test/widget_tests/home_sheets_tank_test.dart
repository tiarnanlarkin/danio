import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/home/home_sheets_tank.dart';
import 'package:danio/services/storage_service.dart';

Tank _tank() {
  final now = DateTime(2026, 1, 1);
  return Tank(
    id: 'tank-1',
    name: 'Test Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

UserProfile _profile() {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    id: 'quick-water-test-profile',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: const [UserGoal.keepFishAlive],
    hasStreakFreeze: false,
    createdAt: now,
    updatedAt: now,
  );
}

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Object? get(String key) => _delegate.get(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> setDouble(String key, double value) =>
      _delegate.setDouble(key, value);

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _delegate.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  Future<void> reload() => _delegate.reload();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({
  InMemoryStorageService? storage,
  SharedPreferences? prefs,
  bool showProfileProbe = false,
}) {
  final resolvedStorage = storage ?? InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(resolvedStorage),
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProfileProbe)
                ref
                    .watch(userProfileProvider)
                    .when(
                      data: (profile) => Text(
                        profile == null ? 'profile missing' : 'profile ready',
                      ),
                      loading: () => const Text('profile loading'),
                      error: (_, __) => const Text('profile unavailable'),
                    ),
              TextButton(
                onPressed: () => showQuickLogSheet(context, ref, _tank()),
                child: const Text('Open quick test'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('quick water test keeps compact field labels readable', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(find.text('Open quick test'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Water Test'), findsOneWidget);
    expect(find.text('pH'), findsOneWidget);
    expect(find.text('Temp'), findsOneWidget);
    expect(find.text('NH3'), findsOneWidget);
    expect(find.textContaining('Temp ('), findsNothing);
  });

  testWidgets('quick water test treats XP failure as non-blocking', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': jsonEncode(_profile().toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    final failingPrefs = _ThrowingSetStringPrefs(
      prefs,
      (key, _) => key == 'user_profile',
    );
    final storage = InMemoryStorageService();

    await tester.pumpWidget(
      _wrap(
        storage: storage,
        prefs: failingPrefs,
        showProfileProbe: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('profile ready'), findsOneWidget);

    await tester.tap(find.text('Open quick test'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'pH'), '7.2');
    await tester.tap(find.text('Save & Earn 10 XP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final logs = await storage.getLogsForTank(_tank().id);
    expect(logs.where((log) => log.type == LogType.waterTest), hasLength(1));
    expect(find.text('Quick Water Test'), findsNothing);
    expect(
      find.text("Couldn't save that water test. Try again."),
      findsNothing,
    );
    expect(
      find.text('Water test logged. XP could not be saved.'),
      findsOneWidget,
    );
  });
}
