import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper around Supabase client.
///
/// Initialise once at app start via [SupabaseService.initialize].
/// Access the shared instance via [SupabaseService.instance].
///
/// All cloud features are additive — the app works without initialising
/// Supabase (offline-first guarantee).
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;

  /// Whether Supabase has been successfully initialised.
  static bool get isInitialised => _instance != null;

  /// Shared singleton. Throws if not yet initialised.
  static SupabaseService get instance {
    assert(_instance != null, 'Call SupabaseService.initialize() first');
    return _instance!;
  }

  // ---------------------------------------------------------------------------
  // TODO: Replace with your dedicated aquarium-app Supabase project credentials.
  //       1. Create a project at https://supabase.com/dashboard
  //       2. Copy the URL and anon key from Project Settings → API
  //       3. Run the migration SQL from lib/supabase/migrations/001_initial.sql
  //       See also: aquarium-roadmap/cloud_setup.md
  // ---------------------------------------------------------------------------
  static const String _supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// The underlying Supabase client.
  SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user (nullable).
  User? get currentUser => client.auth.currentUser;

  /// Whether the user is signed in.
  bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialise Supabase. Call once from main().
  ///
  /// Returns `true` on success, `false` if credentials are placeholders or
  /// initialisation fails (the app continues in offline-only mode).
  static Future<bool> initialize() async {
    if (_instance != null) return true;

    // Skip if credentials are still placeholders
    if (_supabaseUrl.contains('YOUR_PROJECT_REF') ||
        _supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY')) {
      debugPrint('[SupabaseService] Placeholder credentials detected — '
          'running in offline-only mode.');
      return false;
    }

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _instance = SupabaseService._();
      debugPrint('[SupabaseService] Initialised successfully.');
      return true;
    } catch (e, st) {
      debugPrint('[SupabaseService] Initialisation failed: $e\n$st');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience accessors
  // ---------------------------------------------------------------------------

  /// Supabase Storage client.
  SupabaseStorageClient get storage => client.storage;

  /// Shorthand for a table query.
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Realtime client for subscriptions.
  RealtimeClient get realtime => client.realtime;
}
