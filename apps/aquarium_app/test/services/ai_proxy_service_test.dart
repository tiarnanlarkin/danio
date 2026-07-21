import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/api_key_store.dart';
import 'package:danio/services/ai_proxy_service.dart';

void main() {
  late _InMemoryApiKeyStore keyStore;

  setUp(() {
    keyStore = _InMemoryApiKeyStore();
    AiProxyService.overrideApiKeyStoreForTesting(keyStore);
  });

  tearDown(AiProxyService.resetApiKeyStoreForTesting);

  group('AiProxyService local key persistence', () {
    test('saveApiKey writes through ApiKeyStore', () async {
      final credential = _testCredential();

      await AiProxyService.saveApiKey(credential);

      expect(keyStore.value, credential);
      expect(await AiProxyService.getApiKey(), credential);
      expect(await AiProxyService.hasUserKey, isTrue);
    });

    test(
      'saveApiKey reports a secure write failure without a false key',
      () async {
        keyStore.writeError = const ApiKeyStorageException('write');

        await expectLater(
          AiProxyService.saveApiKey(_testCredential()),
          throwsA(isA<ApiKeyStorageException>()),
        );
        expect(await AiProxyService.hasUserKey, isFalse);
      },
    );

    test(
      'clearApiKey reports secure deletion failure without false success',
      () async {
        keyStore.value = _testCredential();
        keyStore.deleteError = const ApiKeyStorageException('delete');

        await expectLater(
          AiProxyService.clearApiKey(),
          throwsA(isA<ApiKeyStorageException>()),
        );
        expect(await AiProxyService.hasUserKey, isTrue);
      },
    );

    test('empty save deletes through ApiKeyStore', () async {
      keyStore.value = _testCredential();

      await AiProxyService.saveApiKey('');

      expect(keyStore.value, isNull);
      expect(await AiProxyService.hasUserKey, isFalse);
    });
  });

  group('AiProxyService release key policy', () {
    test('build-time OpenAI keys are guarded to local dev only', () {
      final source = File(
        'lib/services/ai_proxy_service.dart',
      ).readAsStringSync();

      expect(
        source,
        contains("show kReleaseMode, visibleForTesting"),
        reason:
            'AiProxyService must branch on release mode for build-time keys.',
      );
      expect(
        source,
        contains(
          "if (kReleaseMode) return '';\n"
          "    return const String.fromEnvironment('OPENAI_API_KEY');",
        ),
        reason: 'Build-time OpenAI keys must be empty in release builds.',
      );
      expect(
        source,
        contains('return directBuildTimeApiKey;'),
        reason: 'getApiKey must use the guarded build-time fallback.',
      );
    });
  });
}

String _testCredential() => ['test', 'credential', 'value'].join('-');

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
