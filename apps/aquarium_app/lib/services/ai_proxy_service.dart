// ---------------------------------------------------------------------------
// AI Proxy Service
//
// PRODUCTION REQUIREMENT: All OpenAI requests MUST be routed through a
// server-side proxy (e.g. Supabase Edge Function) to avoid exposing the API
// key in the client bundle.
//
// To enable the proxy, set the SUPABASE_AI_PROXY_URL build-time define:
//   flutter build apk --dart-define=SUPABASE_AI_PROXY_URL=https://your-project.supabase.co/functions/v1/ai-proxy
//
// When SUPABASE_AI_PROXY_URL is set, all AI requests are routed through the
// proxy. The proxy is responsible for injecting the real API key server-side.
// The client sends a Supabase anon key (safe to expose) as the Authorization
// header instead.
//
// When SUPABASE_AI_PROXY_URL is NOT set, the service falls back to direct
// OpenAI calls using a user-supplied key. Build-time OPENAI_API_KEY is a local
// development fallback only and is ignored in release builds.
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import 'api_key_store.dart';

/// Proxy service for obtaining the OpenAI API key and routing AI requests.
///
/// ## Request routing (priority order):
///   1. If `SUPABASE_AI_PROXY_URL` is set → route through the server-side proxy.
///      The proxy injects the real API key; the client uses the Supabase anon key.
///   2. User-supplied key stored through [ApiKeyStore].
///   3. Build-time key from `--dart-define=OPENAI_API_KEY=sk-...`.
class AiProxyService {
  AiProxyService._();

  static ApiKeyStore _apiKeyStore = createDefaultApiKeyStore();

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void overrideApiKeyStoreForTesting(ApiKeyStore store) {
    _apiKeyStore = store;
  }

  @visibleForTesting
  static void resetApiKeyStoreForTesting() {
    _apiKeyStore = createDefaultApiKeyStore();
  }

  // ---------------------------------------------------------------------------
  // Proxy configuration
  // ---------------------------------------------------------------------------

  /// Returns the proxy URL if configured via build-time define.
  ///
  /// In production, this should be your Supabase Edge Function URL.
  /// Example: https://your-project.supabase.co/functions/v1/ai-proxy
  static String get proxyUrl =>
      const String.fromEnvironment('SUPABASE_AI_PROXY_URL');

  /// Safe-to-expose Supabase anon key used to authenticate proxy calls.
  static String get proxyAuthToken =>
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Returns true when a server-side proxy is configured.
  ///
  /// When true, AI requests should be sent to [proxyUrl] instead of directly
  /// to the OpenAI API. The proxy handles API key injection server-side.
  static bool get hasProxy => proxyUrl.isNotEmpty;

  /// Build-time direct OpenAI key for local development only.
  ///
  /// Release builds must not treat an app-owned `OPENAI_API_KEY` define as a
  /// valid configuration path because it would be embedded in the mobile app.
  static String get directBuildTimeApiKey {
    if (kReleaseMode) return '';
    return const String.fromEnvironment('OPENAI_API_KEY');
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the API key for direct OpenAI calls (local dev fallback only).
  ///
  /// IMPORTANT: Do not call this in production if [hasProxy] is true.
  /// In production, send requests to [proxyUrl] with the Supabase anon key.
  ///
  /// Checks secure user storage first; falls back to the build-time define.
  static Future<String> getApiKey() async {
    // Warn if this is called in production (proxy is configured).
    if (hasProxy) {
      appLog(
        'AiProxyService.getApiKey() called but SUPABASE_AI_PROXY_URL is set. '
        'Use proxyUrl and route requests through the proxy instead.',
        tag: 'AiProxyService',
      );
    }

    final userKey = await _apiKeyStore.read();
    if (userKey != null && userKey.isNotEmpty) return userKey;

    return directBuildTimeApiKey;
  }

  /// Returns `true` if any API key is available (proxy, user-supplied, or build-time).
  static Future<bool> get hasApiKey async {
    if (hasProxy) {
      return proxyAuthToken.isNotEmpty;
    }
    final key = await getApiKey();
    return key.isNotEmpty;
  }

  /// Persists a user-supplied API key to platform secure storage.
  static Future<void> saveApiKey(String key) async {
    if (key.isEmpty) {
      await _apiKeyStore.delete();
      return;
    }
    await _apiKeyStore.write(key);
  }

  /// Removes the user-supplied API key from secure and legacy storage.
  static Future<void> clearApiKey() async {
    await _apiKeyStore.delete();
  }

  /// Returns `true` if the user has supplied their own key.
  static Future<bool> get hasUserKey async {
    final value = await _apiKeyStore.read();
    return value != null && value.isNotEmpty;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Async provider that resolves the current API key status.
/// Useful for reactive UI that needs to know if AI is configured.
final aiProxyHasKeyProvider = FutureProvider<bool>((ref) async {
  return AiProxyService.hasApiKey;
});
