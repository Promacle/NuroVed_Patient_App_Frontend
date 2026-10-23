import 'package:flutter/foundation.dart';

/// Central safe logger that automatically scrubs sensitive credentials and personal data.
class AppLogger {
  AppLogger._();

  // Regular expressions for sensitive patterns
  static final RegExp _bearerTokenRegex = RegExp(
    r'(bearer\s+)[a-zA-Z0-9_\-\.]+',
    caseSensitive: false,
  );
  static final RegExp _passwordParamRegex = RegExp(
    r'(password|token|secret|apiKey|api_key|access_token|auth)(\s*[:=]\s*)([^\s,]+)',
    caseSensitive: false,
  );
  static final RegExp _emailRegex = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final RegExp _phoneRegex = RegExp(
    r'(?:\+?\d{1,3}[-.\s]?)?(?:\d{5}[-.\s]?\d{5}|\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})',
  );

  /// Sanitizes sensitive fields from a log string before output.
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    var sanitized = input;
    sanitized = sanitized.replaceAllMapped(
      _bearerTokenRegex,
      (m) => '${m.group(1)}[REDACTED_TOKEN]',
    );
    sanitized = sanitized.replaceAllMapped(
      _passwordParamRegex,
      (m) => '${m.group(1)}${m.group(2)}[REDACTED]',
    );
    sanitized = sanitized.replaceAllMapped(
      _emailRegex,
      (_) => '[REDACTED_EMAIL]',
    );
    sanitized = sanitized.replaceAllMapped(
      _phoneRegex,
      (_) => '[REDACTED_PHONE]',
    );
    return sanitized;
  }

  /// Log debug-level messages (suppressed in release mode).
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kReleaseMode) return;
    _log('DEBUG', message, error, stackTrace);
  }

  /// Log info-level operational events.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  /// Log recoverable warning events.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARN', message, error, stackTrace);
  }

  /// Log application errors.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void _log(
    String level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final sanitizedMsg = sanitize(message);
    final timestamp = DateTime.now().toIso8601String();
    final logLine = '[$timestamp] [$level] $sanitizedMsg';

    debugPrint(logLine);
    if (error != null) {
      debugPrint('   Error: ${sanitize(error.toString())}');
    }
    if (stackTrace != null && !kReleaseMode) {
      debugPrint('   StackTrace: $stackTrace');
    }
  }
}
