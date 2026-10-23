import 'dart:async';
import '../utils/app_logger.dart';
import 'failures.dart';

/// App-wide error mapper that sanitizes and converts exceptions into user-friendly [Failure]s.
class ErrorMapper {
  ErrorMapper._();

  static Failure map(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Mapping error to domain failure', error, stackTrace);

    if (error is Failure) {
      return error;
    }

    if (error is TimeoutException) {
      return const NetworkFailure(
        message: 'The request timed out. Please check your internet connection.',
        code: 'TIMEOUT',
      );
    }

    if (error is FormatException) {
      return ValidationFailure(
        message: 'Data parsing error: ${error.message}',
        code: 'FORMAT_ERROR',
        cause: error,
      );
    }

    final message = error.toString().toLowerCase();

    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('host')) {
      return const NetworkFailure();
    }

    if (message.contains('auth') ||
        message.contains('unauthorized') ||
        message.contains('jwt') ||
        message.contains('token expired')) {
      return const AuthFailure(
        message: 'Your session has expired or authentication failed. Please sign in again.',
        code: 'UNAUTHORIZED',
      );
    }

    if (message.contains('not found') || message.contains('404')) {
      return const NotFoundFailure(
        message: 'The requested resource was not found.',
      );
    }

    return UnexpectedFailure(
      message: 'An unexpected error occurred. Please try again.',
      cause: error,
    );
  }
}
