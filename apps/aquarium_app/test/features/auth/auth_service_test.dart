/// Tests for AuthService — result types, error handling, state transitions
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/features/auth/auth_service.dart';

void main() {
  group('AuthResult', () {
    test('success result has correct status and user reference', () {
      // We can't create a real User without Supabase, but we can test
      // the error/unavailable/pendingRedirect constructors
      const result = AuthResult(
        status: AuthResultStatus.success,
        user: null, // Would normally be a User
      );
      expect(result.status, AuthResultStatus.success);
      expect(result.isSuccess, true);
      expect(result.isError, false);
    });

    test('error result contains error message', () {
      const result = AuthResult.error('Invalid login credentials');
      expect(result.status, AuthResultStatus.error);
      expect(result.isError, true);
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Invalid login credentials');
      expect(result.user, isNull);
    });

    test('unavailable result has informative message', () {
      const result = AuthResult.unavailable();
      expect(result.status, AuthResultStatus.unavailable);
      expect(result.isSuccess, false);
      expect(result.isError, false);
      expect(result.errorMessage, contains('offline'));
      expect(result.user, isNull);
    });

    test('pendingRedirect result for OAuth flow', () {
      const result = AuthResult.pendingRedirect();
      expect(result.status, AuthResultStatus.pendingRedirect);
      expect(result.isSuccess, false);
      expect(result.isError, false);
      expect(result.errorMessage, isNull);
      expect(result.user, isNull);
    });

    test('passwordResetSent result', () {
      const result = AuthResult.passwordResetSent();
      expect(result.status, AuthResultStatus.passwordResetSent);
      expect(result.isSuccess, false);
      expect(result.isError, false);
      expect(result.user, isNull);
    });
  });

  group('AuthResultStatus enum', () {
    test('all expected statuses exist', () {
      expect(AuthResultStatus.values, containsAll([
        AuthResultStatus.success,
        AuthResultStatus.error,
        AuthResultStatus.unavailable,
        AuthResultStatus.pendingRedirect,
        AuthResultStatus.passwordResetSent,
      ]));
    });
  });

  group('AuthService singleton', () {
    test('instance returns the same object', () {
      final a = AuthService.instance;
      final b = AuthService.instance;
      expect(identical(a, b), true);
    });

    test('isSignedIn is false when Supabase not initialised', () {
      // Without Supabase init, _auth is null, currentUser is null
      expect(AuthService.instance.isSignedIn, false);
    });

    test('currentUser is null when Supabase not initialised', () {
      expect(AuthService.instance.currentUser, isNull);
    });
  });

  group('Auth error handling', () {
    test('signUp returns unavailable when Supabase not initialised', () async {
      final result = await AuthService.instance.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result.status, AuthResultStatus.unavailable);
      expect(result.errorMessage, contains('offline'));
    });

    test('signIn returns unavailable when Supabase not initialised', () async {
      final result = await AuthService.instance.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(result.status, AuthResultStatus.unavailable);
    });

    test('signInWithGoogle returns unavailable when Supabase not initialised',
        () async {
      final result = await AuthService.instance.signInWithGoogle();
      expect(result.status, AuthResultStatus.unavailable);
    });

    test('resetPassword returns unavailable when Supabase not initialised',
        () async {
      final result =
          await AuthService.instance.resetPassword('test@example.com');
      expect(result.status, AuthResultStatus.unavailable);
    });

    test('signOut does not throw when Supabase not initialised', () async {
      // Should complete without error
      await AuthService.instance.signOut();
    });
  });

  group('AuthResult error messages for common scenarios', () {
    test('wrong password error', () {
      const result = AuthResult.error('Invalid login credentials');
      expect(result.isError, true);
      expect(result.errorMessage, contains('Invalid'));
    });

    test('email already exists error', () {
      const result = AuthResult.error(
        'User already registered',
      );
      expect(result.isError, true);
      expect(result.errorMessage, contains('already'));
    });

    test('network error', () {
      const result = AuthResult.error(
        'SocketException: Failed host lookup',
      );
      expect(result.isError, true);
      expect(result.errorMessage, contains('Socket'));
    });
  });
}
