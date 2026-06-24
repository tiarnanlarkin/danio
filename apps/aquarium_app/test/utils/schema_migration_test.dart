// Unit tests for SchemaMigration.
//
// Run: flutter test test/utils/schema_migration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/utils/schema_migration.dart';

class _FalseSetIntPrefs implements SharedPreferences {
  _FalseSetIntPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, int value) _shouldFail;

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setInt(String key, int value) async {
    if (_shouldFail(key, value)) return false;
    return _delegate.setInt(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SchemaMigration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stamps version key on first run (v0 → v1)', () async {
      final prefs = await SharedPreferences.getInstance();

      // No version key initially
      expect(prefs.getInt('_schemaVersion'), isNull);

      await SchemaMigration.runIfNeeded(prefs);

      expect(prefs.getInt('_schemaVersion'), 1);
    });

    test('is idempotent — second call does not change version', () async {
      final prefs = await SharedPreferences.getInstance();

      await SchemaMigration.runIfNeeded(prefs);
      final versionAfterFirst = prefs.getInt('_schemaVersion');

      await SchemaMigration.runIfNeeded(prefs);
      final versionAfterSecond = prefs.getInt('_schemaVersion');

      expect(versionAfterSecond, versionAfterFirst);
    });

    test('skips migration when already at target version', () async {
      // Pre-set the version to the current target
      SharedPreferences.setMockInitialValues({'_schemaVersion': 1});
      final prefs = await SharedPreferences.getInstance();

      // Should not throw or change anything
      await SchemaMigration.runIfNeeded(prefs);

      expect(prefs.getInt('_schemaVersion'), 1);
    });

    test('handles prefs with no prior version key gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(() async => SchemaMigration.runIfNeeded(prefs), returnsNormally);
    });

    test('surfaces failed schema version stamp writes', () async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();
      final prefs = _FalseSetIntPrefs(
        delegate,
        (key, _) => key == '_schemaVersion',
      );

      await expectLater(
        SchemaMigration.runIfNeeded(prefs),
        throwsA(isA<StateError>()),
      );

      expect(delegate.getInt('_schemaVersion'), isNull);
    });
  });
}
