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
  // Configure via --dart-define at build time:
  //   flutter build apk --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  //                      --dart-define=SUPABASE_ANON_KEY=your-anon-key
  //
  // If not provided, the app runs in offline-only mode (no cloud sync).
  // See also: aquarium-roadmap/cloud_setup.md
  // ---------------------------------------------------------------------------
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

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

    // Skip if credentials are not configured via --dart-define
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      debugPrint('[SupabaseService] No Supabase credentials configured — '
          'running in offline-only mode. '
          'Configure via --dart-define=SUPABASE_URL=... at build time.');
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
