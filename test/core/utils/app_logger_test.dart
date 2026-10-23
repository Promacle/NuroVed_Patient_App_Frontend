import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/utils/app_logger.dart';

void main() {
  group('AppLogger.sanitize', () {
    test('redacts bearer tokens', () {
      final input = 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz';
      final output = AppLogger.sanitize(input);
      expect(output, contains('Bearer [REDACTED_TOKEN]'));
      expect(output, isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz')));
    });

    test('redacts password parameters', () {
      final input = 'User login failed with password: SecretPass123! and token=abc987xyz';
      final output = AppLogger.sanitize(input);
      expect(output, contains('password: [REDACTED]'));
      expect(output, contains('token=[REDACTED]'));
      expect(output, isNot(contains('SecretPass123!')));
      expect(output, isNot(contains('abc987xyz')));
    });

    test('redacts email addresses', () {
      final input = 'Sending verification to patient@example.com';
      final output = AppLogger.sanitize(input);
      expect(output, contains('[REDACTED_EMAIL]'));
      expect(output, isNot(contains('patient@example.com')));
    });

    test('redacts phone numbers', () {
      final input = 'SMS OTP sent to +91 98765 43210';
      final output = AppLogger.sanitize(input);
      expect(output, contains('[REDACTED_PHONE]'));
      expect(output, isNot(contains('98765 43210')));
    });

    test('preserves harmless non-sensitive messages', () {
      final input = 'Navigation to /home successful';
      expect(AppLogger.sanitize(input), equals(input));
    });
  });
}
