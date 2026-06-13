import 'package:danio/features/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthResult', () {
    test('unavailable copy explains optional cloud account setup', () {
      const result = AuthResult.unavailable();

      expect(result.status, AuthResultStatus.unavailable);
      expect(
        result.errorMessage,
        contains('Optional cloud account services are not configured'),
      );
      expect(result.errorMessage, contains('fully offline'));
      expect(result.errorMessage, isNot(contains('not available')));
    });
  });
}
