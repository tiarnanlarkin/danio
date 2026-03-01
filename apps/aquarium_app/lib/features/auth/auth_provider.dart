import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import 'auth_service.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// Simplified auth state exposed to the UI.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isSignedIn => user != null;
  bool get isSignedOut => user == null && !isLoading;

  String get displayEmail => user?.email ?? '';
  String get displayName =>
      user?.userMetadata?['full_name'] as String? ??
      user?.userMetadata?['name'] as String? ??
      displayEmail;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider - true when a user is logged in.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isSignedIn;
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<AuthState>? _sub;
  // Note: using Supabase's AuthState here via the stream
  StreamSubscription? _authSub;

  void _init() {
    if (!SupabaseService.isInitialised) return;

    // Seed with current user
    final user = AuthService.instance.currentUser;
    state = AuthState(user: user);

    // Listen for changes
    _authSub = AuthService.instance.authStateChanges.listen((event) {
      state = AuthState(user: event.session?.user);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // ---- Actions ----

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await AuthService.instance.signUpWithEmail(
      email: email,
      password: password,
    );
    if (result.isSuccess) {
      state = AuthState(user: result.user);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await AuthService.instance.signInWithEmail(
      email: email,
      password: password,
    );
    if (result.isSuccess) {
      state = AuthState(user: result.user);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await AuthService.instance.signInWithGoogle();
    if (result.isError) {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }
    // On pendingRedirect, keep loading - the auth stream will update state.
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await AuthService.instance.resetPassword(email);
    state = state.copyWith(
      isLoading: false,
      error: result.isError ? result.errorMessage : null,
    );
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
