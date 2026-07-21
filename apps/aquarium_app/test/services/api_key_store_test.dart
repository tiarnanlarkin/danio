import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/api_key_store.dart';

void main() {
  late _InMemoryApiKeyStore secureStore;
  late SharedPreferences preferences;
  late MigratingApiKeyStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    secureStore = _InMemoryApiKeyStore();
    store = MigratingApiKeyStore(
      secureStore: secureStore,
      sharedPreferencesFactory: () async => preferences,
    );
  });

  test('keyless read returns null without creating durable state', () async {
    expect(await store.read(), isNull);
    expect(secureStore.value, isNull);
    expect(preferences.containsKey(legacyApiKeyPreferenceKey), isFalse);
  });

  test('Android secure storage never auto-deletes a key on read error', () {
    expect(
      optionalAiAndroidStorageOptions.toMap()['resetOnError'],
      'false',
    );
  });

  test('write stores only in secure storage and clears legacy state', () async {
    final credential = _testCredential();
    await preferences.setString(
      legacyApiKeyPreferenceKey,
      _legacyEncrypted(credential),
    );

    await store.write(credential);

    expect(secureStore.value, credential);
    expect(preferences.containsKey(legacyApiKeyPreferenceKey), isFalse);
  });

  test(
    'read migrates a legacy value after secure persistence succeeds',
    () async {
      final credential = _testCredential();
      await preferences.setString(
        legacyApiKeyPreferenceKey,
        _legacyEncrypted(credential),
      );

      expect(await store.read(), credential);
      expect(secureStore.value, credential);
      expect(preferences.containsKey(legacyApiKeyPreferenceKey), isFalse);
    },
  );

  test(
    'failed secure migration retains the legacy value and reports safely',
    () async {
      final credential = _testCredential();
      final legacyValue = _legacyEncrypted(credential);
      await preferences.setString(legacyApiKeyPreferenceKey, legacyValue);
      secureStore.writeError = StateError('simulated secure write failure');

      final error = await _captureError(store.read);

      expect(error, isA<ApiKeyMigrationException>());
      expect(preferences.getString(legacyApiKeyPreferenceKey), legacyValue);
      expect(secureStore.value, isNull);
      expect(error.toString(), isNot(contains(credential)));
      expect(error.toString(), isNot(contains(legacyValue)));
    },
  );

  test(
    'failed legacy cleanup keeps the secure copy and reports safely',
    () async {
      final credential = _testCredential();
      final legacyValue = _legacyEncrypted(credential);
      SharedPreferences.setMockInitialValues({
        legacyApiKeyPreferenceKey: legacyValue,
      });
      final delegate = await SharedPreferences.getInstance();
      store = MigratingApiKeyStore(
        secureStore: secureStore,
        sharedPreferencesFactory: () async => _RemoveResultPreferences(
          delegate,
          removeResult: false,
        ),
      );

      final error = await _captureError(store.read);

      expect(error, isA<ApiKeyMigrationException>());
      expect(secureStore.value, credential);
      expect(delegate.getString(legacyApiKeyPreferenceKey), legacyValue);
      expect(error.toString(), isNot(contains(credential)));
      expect(error.toString(), isNot(contains(legacyValue)));
    },
  );

  test('delete clears secure and legacy locations', () async {
    secureStore.value = _testCredential();
    await preferences.setString(
      legacyApiKeyPreferenceKey,
      _legacyEncrypted(_testCredential()),
    );

    await store.delete();

    expect(secureStore.value, isNull);
    expect(preferences.containsKey(legacyApiKeyPreferenceKey), isFalse);
  });

  test('delete still clears legacy state when secure deletion fails', () async {
    final credential = _testCredential();
    secureStore.value = credential;
    secureStore.deleteError = StateError('simulated secure delete failure');
    await preferences.setString(
      legacyApiKeyPreferenceKey,
      _legacyEncrypted(credential),
    );

    final error = await _captureError(store.delete);

    expect(error, isA<ApiKeyDeletionException>());
    expect(secureStore.value, credential);
    expect(preferences.containsKey(legacyApiKeyPreferenceKey), isFalse);
    expect(error.toString(), isNot(contains(credential)));
  });
}

String _testCredential() => ['test', 'credential', 'value'].join('-');

Future<Object> _captureError(Future<void> Function() operation) async {
  try {
    await operation();
  } catch (error) {
    return error;
  }
  fail('Expected operation to throw.');
}

String _legacyEncrypted(String plaintext) {
  const legacySalt = 'danio_ai_proxy_v1';
  final digest = sha256.convert(utf8.encode(legacySalt));
  final key = encrypt_pkg.Key(Uint8List.fromList(digest.bytes));
  final iv = encrypt_pkg.IV.fromSecureRandom(16);
  final encrypter = encrypt_pkg.Encrypter(
    encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
  );
  final encrypted = encrypter.encrypt(plaintext, iv: iv);
  return '${base64.encode(iv.bytes)}:${encrypted.base64}';
}

class _InMemoryApiKeyStore implements ApiKeyStore {
  String? value;
  Object? writeError;
  Object? deleteError;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    final error = writeError;
    if (error != null) throw error;
    this.value = value;
  }

  @override
  Future<void> delete() async {
    final error = deleteError;
    if (error != null) throw error;
    value = null;
  }
}

class _RemoveResultPreferences implements SharedPreferences {
  _RemoveResultPreferences(this._delegate, {required this.removeResult});

  final SharedPreferences _delegate;
  final bool removeResult;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> remove(String key) async => removeResult;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}
