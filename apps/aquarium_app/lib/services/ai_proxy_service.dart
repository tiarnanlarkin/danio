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

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart'
    show Uint8List, kReleaseMode, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// SharedPreferences key for the encrypted user API key.
const String _kUserApiKey = 'user_openai_api_key';

/// A fixed-length salt for key derivation — not a secret, just adds domain
/// separation so the derived key is distinct from any other usage.
const String _kSalt = 'danio_ai_proxy_v1';

/// Proxy service for obtaining the OpenAI API key and routing AI requests.
///
/// ## Request routing (priority order):
///   1. If `SUPABASE_AI_PROXY_URL` is set → route through the server-side proxy.
///      The proxy injects the real API key; the client uses the Supabase anon key.
///   2. User-supplied key stored in SharedPreferences (AES-256 encrypted).
///   3. Build-time key from `--dart-define=OPENAI_API_KEY=sk-...`.
///
/// The user-supplied key is encrypted at rest using AES-256-CBC with a key
/// derived from a deterministic SHA-256 of the salt. This is a best-effort
/// protection against casual extraction; it is NOT a substitute for a
/// server-side proxy — always use the proxy in production.
class AiProxyService {
  AiProxyService._();

  static Future<SharedPreferences> Function() _sharedPreferencesFactory =
      SharedPreferences.getInstance;

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void overrideSharedPreferencesFactoryForTesting(
    Future<SharedPreferences> Function() factory,
  ) {
    _sharedPreferencesFactory = factory;
  }

  @visibleForTesting
  static void resetSharedPreferencesFactoryForTesting() {
    _sharedPreferencesFactory = SharedPreferences.getInstance;
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
  /// Checks SharedPreferences first; falls back to the build-time define.
  static Future<String> getApiKey() async {
    // Warn if this is called in production (proxy is configured).
    if (hasProxy) {
      appLog(
        'AiProxyService.getApiKey() called but SUPABASE_AI_PROXY_URL is set. '
        'Use proxyUrl and route requests through the proxy instead.',
        tag: 'AiProxyService',
      );
    }

    try {
      final prefs = await _sharedPreferencesFactory();
      final encrypted = prefs.getString(_kUserApiKey);
      if (encrypted != null && encrypted.isNotEmpty) {
        final decrypted = _decrypt(encrypted);
        if (decrypted != null && decrypted.isNotEmpty) return decrypted;
      }
    } catch (e) {
      logError(
        'AiProxyService: failed to load user key — $e',
        tag: 'AiProxyService',
      );
    }

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

  /// Persists a user-supplied API key to SharedPreferences (encrypted).
  static Future<void> saveApiKey(String key) async {
    final prefs = await _sharedPreferencesFactory();
    if (key.isEmpty) {
      final removed = await prefs.remove(_kUserApiKey);
      if (!removed) {
        throw StateError('Could not remove Optional AI key locally.');
      }
    } else {
      final saved = await prefs.setString(_kUserApiKey, _encrypt(key));
      if (!saved) {
        throw StateError('Could not save Optional AI key locally.');
      }
    }
  }

  /// Removes the user-supplied API key from SharedPreferences.
  static Future<void> clearApiKey() async {
    final prefs = await _sharedPreferencesFactory();
    final removed = await prefs.remove(_kUserApiKey);
    if (!removed) {
      throw StateError('Could not remove Optional AI key locally.');
    }
  }

  /// Returns `true` if the user has supplied their own key.
  static Future<bool> get hasUserKey async {
    final prefs = await _sharedPreferencesFactory();
    final value = prefs.getString(_kUserApiKey);
    return value != null && value.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Encryption helpers (AES-256-CBC)
  // ---------------------------------------------------------------------------

  static encrypt_pkg.Key get _key {
    final saltBytes = utf8.encode(_kSalt);
    final digest = sha256.convert(saltBytes);
    return encrypt_pkg.Key(Uint8List.fromList(digest.bytes));
  }

  static String _encrypt(String plaintext) {
    final iv = encrypt_pkg.IV.fromSecureRandom(16);
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    // Encode as base64(iv) + ':' + base64(ciphertext) for easy splitting.
    final ivB64 = base64.encode(iv.bytes);
    final cipherB64 = encrypted.base64;
    return '$ivB64:$cipherB64';
  }

  static String? _decrypt(String stored) {
    try {
      final parts = stored.split(':');
      if (parts.length != 2) return null;
      final iv = encrypt_pkg.IV(Uint8List.fromList(base64.decode(parts[0])));
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.cbc),
      );
      return encrypter.decrypt(
        encrypt_pkg.Encrypted(Uint8List.fromList(base64.decode(parts[1]))),
        iv: iv,
      );
    } catch (e) {
      logError('AiProxyService: decryption failed — $e', tag: 'AiProxyService');
      return null;
    }
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
