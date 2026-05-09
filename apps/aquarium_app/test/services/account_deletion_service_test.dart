import 'package:flutter_test/flutter_test.dart';
import 'package:danio/services/account_deletion_service.dart';

void main() {
  group('AccountDeletionService', () {
    test('signs out only after cloud account deletion succeeds', () async {
      final gateway = _FakeAccountDeletionGateway();
      final service = AccountDeletionService(gateway: gateway);

      await service.deleteCloudAccount();

      expect(gateway.deleteCalls, 1);
      expect(gateway.signOutCalls, 1);
    });

    test('does not sign out when cloud account deletion fails', () async {
      final gateway = _FakeAccountDeletionGateway(
        deletionError: const AccountDeletionException('backend failed'),
      );
      final service = AccountDeletionService(gateway: gateway);

      await expectLater(
        service.deleteCloudAccount(),
        throwsA(isA<AccountDeletionException>()),
      );

      expect(gateway.deleteCalls, 1);
      expect(gateway.signOutCalls, 0);
    });
  });
}

class _FakeAccountDeletionGateway implements AccountDeletionGateway {
  _FakeAccountDeletionGateway({this.deletionError});

  final Object? deletionError;
  int deleteCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> invokeCloudAccountDeletion() async {
    deleteCalls += 1;
    final error = deletionError;
    if (error != null) throw error;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}
