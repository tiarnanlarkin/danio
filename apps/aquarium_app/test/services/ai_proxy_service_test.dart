import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/ai_proxy_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(AiProxyService.resetSharedPreferencesFactoryForTesting);

  group('AiProxyService local key persistence', () {
    test('saveApiKey throws when local key write returns false', () async {
      final prefs = await SharedPreferences.getInstance();
      AiProxyService.overrideSharedPreferencesFactoryForTesting(
        () async => _WriteResultPrefs(prefs, failSetString: true),
      );

      await expectLater(
        AiProxyService.saveApiKey('sk-test-key'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Could not save Optional AI key'),
          ),
        ),
      );
      expect(await AiProxyService.hasUserKey, isFalse);
    });

    test('clearApiKey throws when local key removal returns false', () async {
      SharedPreferences.setMockInitialValues({
        'user_openai_api_key': 'existing-encrypted-key',
      });
      final prefs = await SharedPreferences.getInstance();
      AiProxyService.overrideSharedPreferencesFactoryForTesting(
        () async => _WriteResultPrefs(prefs, failRemove: true),
      );

      await expectLater(
        AiProxyService.clearApiKey(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Could not remove Optional AI key'),
          ),
        ),
      );
      expect(await AiProxyService.hasUserKey, isTrue);
    });
  });

  group('AiProxyService release key policy', () {
    test('build-time OpenAI keys are guarded to local dev only', () {
      final source = File(
        'lib/services/ai_proxy_service.dart',
      ).readAsStringSync();

      expect(
        source,
        contains("show Uint8List, kReleaseMode"),
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

class _WriteResultPrefs implements SharedPreferences {
  _WriteResultPrefs(
    this._delegate, {
    this.failSetString = false,
    this.failRemove = false,
  });

  final SharedPreferences _delegate;
  final bool failSetString;
  final bool failRemove;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> remove(String key) async {
    if (failRemove) return false;
    return _delegate.remove(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    if (failSetString) return false;
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
