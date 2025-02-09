enum ErrorSource {
  auth,
  database,
  network,
  validation,
  unknown,
}

class AppError implements Exception {
  final String message;
  final ErrorSource source;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.source,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class AuthError extends AppError {
  AuthError({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          source: ErrorSource.auth,
        );

  // Factory constructors for common auth errors
  factory AuthError.invalidCredentials(
      {dynamic originalError, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Invalid email or password',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AuthError.emailAlreadyInUse(
      {dynamic originalError, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Email is already in use',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AuthError.weakPassword(
      {dynamic originalError, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Password is too weak',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AuthError.userNotFound(
      {dynamic originalError, StackTrace? stackTrace}) {
    return AuthError(
      message: 'User not found',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AuthError.emailNotVerified(
      {dynamic originalError, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Email not verified',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

class DatabaseError extends AppError {
  DatabaseError({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          source: ErrorSource.database,
        );
}

class NetworkError extends AppError {
  NetworkError({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          source: ErrorSource.network,
        );

  factory NetworkError.connectionFailed(
      {dynamic originalError, StackTrace? stackTrace}) {
    return NetworkError(
      message: 'Connection failed. Please check your internet connection',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory NetworkError.timeout(
      {dynamic originalError, StackTrace? stackTrace}) {
    return NetworkError(
      message: 'Request timed out. Please try again',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

class ValidationError extends AppError {
  ValidationError({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          source: ErrorSource.validation,
        );
}
