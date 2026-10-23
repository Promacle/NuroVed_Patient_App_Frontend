import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/utils/validators.dart';

void main() {
  group('AppValidators.email', () {
    test('accepts valid email addresses', () {
      expect(AppValidators.email('test@example.com'), isNull);
      expect(AppValidators.email('patient.care@hospital.org'), isNull);
      expect(AppValidators.email('user+filter@sub.domain.co'), isNull);
    });

    test('rejects empty or whitespace-only email', () {
      expect(AppValidators.email(null), contains('required'));
      expect(AppValidators.email(''), contains('required'));
      expect(AppValidators.email('   '), contains('required'));
    });

    test('rejects malformed email addresses', () {
      expect(AppValidators.email('plainaddress'), contains('valid'));
      expect(AppValidators.email('@missingusername.com'), contains('valid'));
      expect(AppValidators.email('username@.com'), contains('valid'));
      expect(AppValidators.email('user@domain.'), contains('valid'));
      expect(AppValidators.email('user@domain..com'), contains('valid'));
      expect(AppValidators.email('user name@domain.com'), contains('valid'));
    });
  });

  group('AppValidators.phone', () {
    test('accepts valid Indian and international numbers', () {
      expect(AppValidators.phone('9123456780'), isNull);
      expect(AppValidators.phone('+91 91234 56780'), isNull);
      expect(AppValidators.phone('+91-9123456780'), isNull);
      expect(AppValidators.phone('09123456780'), isNull);
      expect(AppValidators.phone('+14155552671'), isNull);
    });

    test('rejects empty or whitespace-only phone', () {
      expect(AppValidators.phone(null), contains('required'));
      expect(AppValidators.phone(''), contains('required'));
    });

    test(
      'rejects phone numbers with alphabetic characters or invalid length',
      () {
        expect(AppValidators.phone('91234abcde'), contains('digits'));
        expect(AppValidators.phone('12345'), contains('valid'));
        expect(AppValidators.phone('12345678901234567'), contains('valid'));
      },
    );
  });

  group('AppValidators.dateOfBirth', () {
    test('accepts valid calendar dates', () {
      expect(AppValidators.dateOfBirth('15/08/1990'), isNull);
      expect(AppValidators.dateOfBirth('2000-01-31'), isNull);
      // Leap year Feb 29
      expect(AppValidators.dateOfBirth('29/02/2004'), isNull);
    });

    test('rejects invalid leap year dates', () {
      expect(
        AppValidators.dateOfBirth('29/02/2003'),
        contains('Day must be between 1 and 28'),
      );
    });

    test('rejects days exceeding month length', () {
      expect(
        AppValidators.dateOfBirth('31/04/2000'),
        contains('Day must be between 1 and 30'),
      );
      expect(
        AppValidators.dateOfBirth('32/01/2000'),
        contains('Day must be between 1 and 31'),
      );
    });

    test('rejects future dates', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final formatted =
          '${tomorrow.day.toString().padLeft(2, '0')}/${tomorrow.month.toString().padLeft(2, '0')}/${tomorrow.year}';
      expect(AppValidators.dateOfBirth(formatted), contains('future'));
    });

    test('rejects ages greater than 125', () {
      expect(AppValidators.dateOfBirth('01/01/1850'), contains('realistic'));
    });

    test('rejects invalid format or empty input', () {
      expect(AppValidators.dateOfBirth(null), contains('required'));
      expect(AppValidators.dateOfBirth('not-a-date'), contains('valid'));
      expect(
        AppValidators.dateOfBirth('15/13/2000'),
        contains('Month must be between 1 and 12'),
      );
    });
  });

  group('AppValidators.requiredField', () {
    test('validates non-empty strings', () {
      expect(AppValidators.requiredField('Valid Name', 'Full Name'), isNull);
    });

    test('rejects null and whitespace', () {
      expect(
        AppValidators.requiredField(null, 'Full Name'),
        equals('Full Name is required'),
      );
      expect(
        AppValidators.requiredField('   ', 'Full Name'),
        equals('Full Name is required'),
      );
    });
  });

  group('AppValidators.numericMeasurement', () {
    test('accepts numbers within biological bounds', () {
      expect(
        AppValidators.numericMeasurement(
          '175',
          min: 30,
          max: 280,
          fieldName: 'Height',
          unit: 'cm',
        ),
        isNull,
      );
      expect(
        AppValidators.numericMeasurement(
          '70.5',
          min: 2,
          max: 400,
          fieldName: 'Weight',
          unit: 'kg',
        ),
        isNull,
      );
      expect(
        AppValidators.numericMeasurement(
          '5.7',
          min: 3,
          max: 20,
          fieldName: 'HbA1c',
          unit: '%',
        ),
        isNull,
      );
    });

    test('rejects numbers outside bounds', () {
      expect(
        AppValidators.numericMeasurement(
          '20',
          min: 30,
          max: 280,
          fieldName: 'Height',
          unit: 'cm',
        ),
        contains('cannot be less than 30.0 cm'),
      );
      expect(
        AppValidators.numericMeasurement(
          '500',
          min: 2,
          max: 400,
          fieldName: 'Weight',
          unit: 'kg',
        ),
        contains('cannot exceed 400.0 kg'),
      );
    });

    test('rejects non-numeric inputs', () {
      expect(
        AppValidators.numericMeasurement('abc', min: 10, max: 100),
        contains('valid number'),
      );
      expect(
        AppValidators.numericMeasurement(null, min: 10, max: 100),
        contains('required'),
      );
    });
  });

  group('AppValidators.fileTypeAndSize', () {
    test('accepts valid file types and sizes', () {
      expect(
        AppValidators.fileTypeAndSize(
          fileName: 'blood_report.pdf',
          byteLength: 1024 * 500, // 500 KB
          allowedExtensions: ['pdf', 'jpg', 'png'],
          maxBytes: 10 * 1024 * 1024, // 10 MB
        ),
        isNull,
      );
    });

    test('rejects unauthorized extensions', () {
      expect(
        AppValidators.fileTypeAndSize(
          fileName: 'malicious.exe',
          byteLength: 1024,
          allowedExtensions: ['pdf', 'jpg', 'png'],
          maxBytes: 10 * 1024 * 1024,
        ),
        contains('not allowed'),
      );
    });

    test('rejects oversized files', () {
      expect(
        AppValidators.fileTypeAndSize(
          fileName: 'large_scan.pdf',
          byteLength: 15 * 1024 * 1024, // 15 MB
          allowedExtensions: ['pdf'],
          maxBytes: 10 * 1024 * 1024, // 10 MB limit
        ),
        contains('exceeds maximum allowed limit of 10.0MB'),
      );
    });

    test('rejects empty files', () {
      expect(
        AppValidators.fileTypeAndSize(
          fileName: 'empty.pdf',
          byteLength: 0,
          allowedExtensions: ['pdf'],
          maxBytes: 10 * 1024 * 1024,
        ),
        contains('empty'),
      );
    });
  });
}
