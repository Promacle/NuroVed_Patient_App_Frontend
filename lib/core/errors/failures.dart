import 'package:flutter/foundation.dart';

/// Base class for all application failures and domain errors.
@immutable
abstract class Failure {
  final String message;
  final String? code;
  final dynamic cause;

  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed. Please check your internet connectivity.',
    super.code = 'NETWORK_ERROR',
    super.cause,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.cause,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.cause,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
    super.cause,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'An unexpected server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
    super.cause,
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.cause,
  });
}

class ConfigFailure extends Failure {
  const ConfigFailure({
    super.message = 'Backend configuration is missing or invalid.',
    super.code = 'CONFIG_MISSING',
    super.cause,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNEXPECTED_ERROR',
    super.cause,
  });
}
