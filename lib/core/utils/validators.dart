/// Central reusable validation utility for medical, authentication, and form inputs.
class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed) || trimmed.endsWith('.')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a phone number (E.164 or Indian 10-digit format).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final digitsOnly = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;

    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return 'Phone number must contain only digits';
    }

    // Support standard 10-digit mobile, with optional 91 or 0 prefix
    if (digitsOnly.length == 10) {
      return null;
    }
    if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      return null;
    }
    if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      return null;
    }
    // General international length bounds: 7 to 15 digits
    if (digitsOnly.length >= 7 && digitsOnly.length <= 15) {
      return null;
    }

    return 'Please enter a valid phone number';
  }

  /// Validates a date of birth in DD/MM/YYYY or YYYY-MM-DD format.
  /// Enforces calendar validity, rejects future dates and ages > 125.
  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }
    final trimmed = value.trim();

    int? day, month, year;

    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length != 3) {
        return 'Please enter date in DD/MM/YYYY format';
      }
      day = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      year = int.tryParse(parts[2]);
    } else if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      if (parts.length != 3) {
        return 'Please enter date in YYYY-MM-DD format';
      }
      year = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      day = int.tryParse(parts[2]);
    } else {
      return 'Please enter a valid date';
    }

    if (day == null || month == null || year == null) {
      return 'Date must contain valid numeric parts';
    }

    if (month < 1 || month > 12) {
      return 'Month must be between 1 and 12';
    }

    if (year < 1800) {
      return 'Please enter a realistic date of birth';
    }

    // Days in month validation
    final daysInMonth = _daysInMonth(year, month);
    if (day < 1 || day > daysInMonth) {
      return 'Day must be between 1 and $daysInMonth for the selected month';
    }

    final parsedDate = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (parsedDate.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }

    // Age validation (> 125 years old)
    var age = today.year - parsedDate.year;
    if (today.month < parsedDate.month ||
        (today.month == parsedDate.month && today.day < parsedDate.day)) {
      age--;
    }

    if (age > 125) {
      return 'Please enter a realistic date of birth';
    }

    return null;
  }

  static int _daysInMonth(int year, int month) {
    switch (month) {
      case 2:
        final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        return isLeapYear ? 29 : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  /// Validates that a string field is not empty.
  static String? requiredField(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a numeric measurement within realistic biological bounds.
  static String? numericMeasurement(
    String? value, {
    required double min,
    required double max,
    String fieldName = 'Value',
    String? unit,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName must be a valid number';
    }
    final unitSuffix = unit != null ? ' $unit' : '';
    if (parsed < min) {
      return '$fieldName cannot be less than $min$unitSuffix';
    }
    if (parsed > max) {
      return '$fieldName cannot exceed $max$unitSuffix';
    }
    return null;
  }

  /// Validates uploaded file type (extension) and size.
  static String? fileTypeAndSize({
    required String fileName,
    required int byteLength,
    required List<String> allowedExtensions,
    required int maxBytes,
  }) {
    if (fileName.trim().isEmpty) {
      return 'File name is required';
    }
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return 'File has no extension';
    }
    final ext = fileName.substring(dotIndex + 1).toLowerCase();
    final normalizedAllowed = allowedExtensions.map((e) => e.toLowerCase()).toList();

    if (!normalizedAllowed.contains(ext)) {
      return 'File format .$ext is not allowed. Supported formats: ${allowedExtensions.join(", ")}';
    }

    if (byteLength <= 0) {
      return 'File cannot be empty';
    }

    if (byteLength > maxBytes) {
      final maxMb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size exceeds maximum allowed limit of ${maxMb}MB';
    }

    return null;
  }
}
