import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';

/// Authentication service wrapping Supabase Auth.
///
/// Supports email+password and Google OAuth.
/// All methods are safe to call when Supabase is not initialised -
/// they return appropriate error states without throwing.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool get _available => SupabaseService.isInitialised;
  GoTrueClient? get _auth =>
      _available ? SupabaseService.instance.client.auth : null;

  User? get currentUser => _auth?.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _auth?.onAuthStateChange ?? const Stream.empty();

  // ---------------------------------------------------------------------------
  // Email + Password
  // ---------------------------------------------------------------------------

  /// Sign up with email and password. Returns the user on success.
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_available) return const AuthResult.unavailable();
    try {
      final response = await _auth!.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return AuthResult.success(response.user!);
      }
      return const AuthResult.error('Sign-up succeeded but no user returned.');
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Sign in with email and password.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_available) return const AuthResult.unavailable();
    try {
      final response = await _auth!.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return AuthResult.success(response.user!);
      }
      return const AuthResult.error('Sign-in succeeded but no user returned.');
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Google OAuth
  // ---------------------------------------------------------------------------

  /// Sign in with Google via Supabase OAuth.
  Future<AuthResult> signInWithGoogle() async {
    if (!_available) return const AuthResult.unavailable();
    try {
      final success = await _auth!.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.aquariumapp://login-callback/',
      );
      if (success) {
        // OAuth redirect flow - the actual user object arrives via
        // authStateChanges after the browser redirect completes.
        return const AuthResult.pendingRedirect();
      }
      return const AuthResult.error('Google sign-in was cancelled.');
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Send a password-reset email.
  Future<AuthResult> resetPassword(String email) async {
    if (!_available) return const AuthResult.unavailable();
    try {
      await _auth!.resetPasswordForEmail(email);
      return const AuthResult.passwordResetSent();
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    if (!_available) return;
    try {
      await _auth!.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign-out error: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Result type
// ---------------------------------------------------------------------------

enum AuthResultStatus {
  success,
  error,
  unavailable,
  pendingRedirect,
  passwordResetSent,
}

class AuthResult {
  final AuthResultStatus status;
  final User? user;
  final String? errorMessage;

  const AuthResult({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthResult.success(User this.user)
      : status = AuthResultStatus.success,
        errorMessage = null;

  const AuthResult.error(String this.errorMessage)
      : status = AuthResultStatus.error,
        user = null;

  const AuthResult.unavailable()
      : status = AuthResultStatus.unavailable,
        user = null,
        errorMessage = 'Cloud services are not available. '
            'The app works fully offline.';

  const AuthResult.pendingRedirect()
      : status = AuthResultStatus.pendingRedirect,
        user = null,
        errorMessage = null;

  const AuthResult.passwordResetSent()
      : status = AuthResultStatus.passwordResetSent,
        user = null,
        errorMessage = null;

  bool get isSuccess => status == AuthResultStatus.success;
  bool get isError => status == AuthResultStatus.error;
}
