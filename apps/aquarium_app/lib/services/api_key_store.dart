import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String legacyApiKeyPreferenceKey = 'user_openai_api_key';

const AndroidOptions optionalAiAndroidStorageOptions = AndroidOptions(
  resetOnError: false,
);

const String _secureApiKeyStorageKey = 'danio_optional_ai_openai_key';
const String _legacyKeySalt = 'danio_ai_proxy_v1';

abstract interface class ApiKeyStore {
  Future<String?> read();

  Future<void> write(String value);

  Future<void> delete();
}

class ApiKeyStorageException implements Exception {
  const ApiKeyStorageException(
    this.operation, {
    this.originalError,
    this.originalStackTrace,
  });

  final String operation;
  final Object? originalError;
  final StackTrace? originalStackTrace;

  @override
  String toString() =>
      'Optional AI key storage could not complete the $operation operation.';
}

class ApiKeyMigrationException extends ApiKeyStorageException {
  const ApiKeyMigrationException({
    required super.originalError,
    required super.originalStackTrace,
  }) : super('legacy migration');
}

class ApiKeyDeletionException extends ApiKeyStorageException {
  const ApiKeyDeletionException({
    this.secureDeleteError,
    this.secureDeleteStackTrace,
    this.legacyDeleteError,
    this.legacyDeleteStackTrace,
  }) : super('delete');

  final Object? secureDeleteError;
  final StackTrace? secureDeleteStackTrace;
  final Object? legacyDeleteError;
  final StackTrace? legacyDeleteStackTrace;
}

class FlutterSecureApiKeyStore implements ApiKeyStore {
  const FlutterSecureApiKeyStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: optionalAiAndroidStorageOptions,
    ),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _secureApiKeyStorageKey);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyStorageException(
          'read',
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> write(String value) async {
    try {
      await _storage.write(key: _secureApiKeyStorageKey, value: value);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyStorageException(
          'write',
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: _secureApiKeyStorageKey);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyStorageException(
          'delete',
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

class MigratingApiKeyStore implements ApiKeyStore {
  MigratingApiKeyStore({
    required ApiKeyStore secureStore,
    required Future<SharedPreferences> Function() sharedPreferencesFactory,
  }) : _secureStore = secureStore,
       _sharedPreferencesFactory = sharedPreferencesFactory;

  final ApiKeyStore _secureStore;
  final Future<SharedPreferences> Function() _sharedPreferencesFactory;

  @override
  Future<String?> read() async {
    final secureValue = await _secureStore.read();
    final preferences = await _preferencesFor('read');
    final legacyValue = _legacyValueFrom(preferences);

    if (secureValue != null && secureValue.isNotEmpty) {
      if (legacyValue != null) {
        await _removeLegacyAfterSecurePersistence(preferences);
      }
      return secureValue;
    }

    if (legacyValue == null || legacyValue.isEmpty) return null;

    final plaintext = _decryptLegacyValue(legacyValue);
    if (plaintext == null || plaintext.isEmpty) {
      final error = StateError('Legacy Optional AI key could not be decoded.');
      throw ApiKeyMigrationException(
        originalError: error,
        originalStackTrace: StackTrace.current,
      );
    }

    try {
      await _secureStore.write(plaintext);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyMigrationException(
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }

    await _removeLegacyAfterSecurePersistence(preferences);
    return plaintext;
  }

  @override
  Future<void> write(String value) async {
    if (value.isEmpty) {
      await delete();
      return;
    }

    await _secureStore.write(value);
    final preferences = await _preferencesFor('write');
    await _removeLegacyAfterSecurePersistence(preferences);
  }

  @override
  Future<void> delete() async {
    Object? secureDeleteError;
    StackTrace? secureDeleteStackTrace;
    Object? legacyDeleteError;
    StackTrace? legacyDeleteStackTrace;

    try {
      await _secureStore.delete();
    } catch (error, stackTrace) {
      secureDeleteError = error;
      secureDeleteStackTrace = stackTrace;
    }

    try {
      final preferences = await _preferencesFor('delete');
      await _removeLegacy(preferences);
    } catch (error, stackTrace) {
      legacyDeleteError = error;
      legacyDeleteStackTrace = stackTrace;
    }

    if (secureDeleteError != null || legacyDeleteError != null) {
      final stackTrace =
          secureDeleteStackTrace ??
          legacyDeleteStackTrace ??
          StackTrace.current;
      Error.throwWithStackTrace(
        ApiKeyDeletionException(
          secureDeleteError: secureDeleteError,
          secureDeleteStackTrace: secureDeleteStackTrace,
          legacyDeleteError: legacyDeleteError,
          legacyDeleteStackTrace: legacyDeleteStackTrace,
        ),
        stackTrace,
      );
    }
  }

  Future<SharedPreferences> _preferencesFor(String operation) async {
    try {
      return await _sharedPreferencesFactory();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyStorageException(
          operation,
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  String? _legacyValueFrom(SharedPreferences preferences) {
    try {
      return preferences.getString(legacyApiKeyPreferenceKey);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyStorageException(
          'read',
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  Future<void> _removeLegacyAfterSecurePersistence(
    SharedPreferences preferences,
  ) async {
    try {
      await _removeLegacy(preferences);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ApiKeyMigrationException(
          originalError: error,
          originalStackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  Future<void> _removeLegacy(SharedPreferences preferences) async {
    if (!preferences.containsKey(legacyApiKeyPreferenceKey)) return;
    final removed = await preferences.remove(legacyApiKeyPreferenceKey);
    if (!removed) {
      throw StateError('Legacy Optional AI key removal failed.');
    }
  }

  String? _decryptLegacyValue(String stored) {
    try {
      final parts = stored.split(':');
      if (parts.length != 2) return null;
      final digest = sha256.convert(utf8.encode(_legacyKeySalt));
      final key = encrypt_pkg.Key(Uint8List.fromList(digest.bytes));
      final iv = encrypt_pkg.IV(
        Uint8List.fromList(base64.decode(parts.first)),
      );
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );
      return encrypter.decrypt(
        encrypt_pkg.Encrypted(
          Uint8List.fromList(base64.decode(parts.last)),
        ),
        iv: iv,
      );
    } on Object {
      return null;
    }
  }
}

ApiKeyStore createDefaultApiKeyStore() {
  return MigratingApiKeyStore(
    secureStore: const FlutterSecureApiKeyStore(),
    sharedPreferencesFactory: SharedPreferences.getInstance,
  );
}
