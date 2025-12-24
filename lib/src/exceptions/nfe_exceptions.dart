/// Base exception for NFe downloader
abstract class NfeException implements Exception {
  /// The error message
  final String message;

  /// The original error that caused this exception (if any)
  final dynamic originalError;

  /// The stack trace (if available)
  final StackTrace? stackTrace;

  const NfeException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() =>
      'NfeException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Exception thrown when Anti-Captcha API fails
class AntiCaptchaException extends NfeException {
  /// The error code returned by Anti-Captcha
  final String? errorCode;

  const AntiCaptchaException(
    String message, {
    this.errorCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError, stackTrace);

  @override
  String toString() =>
      'AntiCaptchaException: $message${errorCode != null ? ' (code: $errorCode)' : ''}';
}

/// Exception thrown when captcha solving times out
class CaptchaTimeoutException extends NfeException {
  const CaptchaTimeoutException(
    super.message, [
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String toString() => 'CaptchaTimeoutException: $message';
}

/// Exception thrown when NFe-Cidades API fails
class NfeApiException extends NfeException {
  /// The HTTP status code (if applicable)
  final int? statusCode;

  const NfeApiException(
    String message, {
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError, stackTrace);

  @override
  String toString() =>
      'NfeApiException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Exception thrown when document is not found
class DocumentNotFoundException extends NfeApiException {
  const DocumentNotFoundException(
    super.message, {
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DocumentNotFoundException: $message';
}

/// Exception thrown when senha is invalid
class InvalidSenhaException extends NfeApiException {
  const InvalidSenhaException(
    super.message, {
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'InvalidSenhaException: $message';
}

/// Exception thrown for network-related errors
class NetworkException extends NfeException {
  const NetworkException(
    super.message, [
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when operation times out
class TimeoutException extends NfeException {
  const TimeoutException(
    super.message, [
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String toString() => 'TimeoutException: $message';
}
