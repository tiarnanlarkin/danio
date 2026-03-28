// TODO: Route through server-side proxy (Supabase Edge Function) before
// production release. Client-side key is a stopgap.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// SharedPreferences key for the encrypted user API key.
const String _kUserApiKey = 'user_openai_api_key';

/// A fixed-length salt for key derivation — not a secret, just adds domain
/// separation so the derived key is distinct from any other usage.
const String _kSalt = 'danio_ai_proxy_v1';

/// Proxy service for obtaining the OpenAI API key.
///
/// Priority order:
///   1. User-supplied key stored in SharedPreferences (AES-256 encrypted).
///   2. Build-time key from `--dart-define=OPENAI_API_KEY=sk-...`.
///
/// The user-supplied key is encrypted at rest using AES-256-CBC with a key
/// derived from a deterministic SHA-256 of the salt + a device-stable value
/// (the salt itself, since we have no device UID at this layer). This is a
/// best-effort protection against casual extraction; it is NOT a substitute
/// for a server-side proxy.
class AiProxyService {
  AiProxyService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the API key, or an empty string if none is configured.
  ///
  /// Checks SharedPreferences first; falls back to the build-time define.
  static Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString(_kUserApiKey);
      if (encrypted != null && encrypted.isNotEmpty) {
        final decrypted = _decrypt(encrypted);
        if (decrypted != null && decrypted.isNotEmpty) return decrypted;
      }
    } catch (e) {
      logError('AiProxyService: failed to load user key — $e',
          tag: 'AiProxyService');
    }

    // Fall back to build-time define.
    return const String.fromEnvironment('OPENAI_API_KEY');
  }

  /// Returns `true` if any API key is available (user-supplied or build-time).
  static Future<bool> get hasApiKey async {
    final key = await getApiKey();
    return key.isNotEmpty;
  }

  /// Persists a user-supplied API key to SharedPreferences (encrypted).
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key.isEmpty) {
      await prefs.remove(_kUserApiKey);
    } else {
      await prefs.setString(_kUserApiKey, _encrypt(key));
    }
  }

  /// Removes the user-supplied API key from SharedPreferences.
  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserApiKey);
  }

  /// Returns `true` if the user has supplied their own key.
  static Future<bool> get hasUserKey async {
    final prefs = await SharedPreferences.getInstance();
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
