import 'package:danio/features/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthResult', () {
    test('unavailable copy explains optional cloud account setup', () {
      const result = AuthResult.unavailable();

      expect(result.status, AuthResultStatus.unavailable);
      expect(
        result.errorMessage,
        contains('Optional cloud account features are not set up'),
      );
      expect(result.errorMessage, contains('Danio still works offline'));
      expect(result.errorMessage, isNot(contains('configured')));
      expect(result.errorMessage, isNot(contains('this build')));
      expect(result.errorMessage, isNot(contains('not available')));
    });
  });
}
