import '../features/auth/auth_service.dart';
import '../utils/logger.dart';
import 'supabase_service.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AccountDeletionException: $message';
}

abstract class AccountDeletionGateway {
  Future<void> invokeCloudAccountDeletion();

  Future<void> signOut();
}

class SupabaseAccountDeletionGateway implements AccountDeletionGateway {
  const SupabaseAccountDeletionGateway();

  @override
  Future<void> invokeCloudAccountDeletion() async {
    if (!SupabaseService.isInitialised) {
      throw const AccountDeletionException(
        'Cloud services are not available in this build.',
      );
    }

    final service = SupabaseService.instance;
    if (service.currentUser == null) {
      throw const AccountDeletionException('No signed-in account to delete.');
    }

    try {
      await service.client.functions.invoke('delete-user-account');
    } catch (e, st) {
      logError(
        'Account deletion function failed: $e',
        stackTrace: st,
        tag: 'AccountDeletionService',
      );
      throw AccountDeletionException(
        'Your account could not be deleted. Please try again.',
        cause: e,
      );
    }
  }

  @override
  Future<void> signOut() => AuthService.instance.signOut();
}

class AccountDeletionService {
  AccountDeletionService({AccountDeletionGateway? gateway})
    : _gateway = gateway ?? const SupabaseAccountDeletionGateway();

  static final AccountDeletionService instance = AccountDeletionService();

  final AccountDeletionGateway _gateway;

  Future<void> deleteCloudAccount() async {
    await _gateway.invokeCloudAccountDeletion();
    await _gateway.signOut();
  }
}
