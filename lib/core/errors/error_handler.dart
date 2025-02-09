import 'package:erp/core/errors/error_model.dart';
import 'package:erp/core/errors/error_localizer.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ErrorHandler {
  final AppLogger _logger = AppLogger();

  AppError handleException(dynamic error,
      {StackTrace? stackTrace, String? context}) {
    _logger.logError(error, stackTrace: stackTrace, context: context);

    // If it's already our AppError type, return it
    if (error is AppError) {
      return error;
    }

    // Handle Supabase Auth Errors
    if (error is supabase.AuthException) {
      return _handleAuthException(error, stackTrace);
    }

    // Handle Supabase PostgrestException (database errors)
    if (error is supabase.PostgrestException) {
      return DatabaseError(
        message: error.message,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection failed')) {
      return NetworkError.connectionFailed(
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timed out')) {
      return NetworkError.timeout(
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Handle other specific error types...

    // Fallback for unhandled error types
    return AppError(
      message: 'An error occurred. Please try again',
      source: ErrorSource.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  AuthError _handleAuthException(
      supabase.AuthException error, StackTrace? stackTrace) {
    _logger.logDebug(
        'Handling auth exception: ${error.message} (${error.statusCode})');

    switch (error.statusCode) {
      case '400':
        if (error.message.contains('already')) {
          return AuthError.emailAlreadyInUse(
            originalError: error,
            stackTrace: stackTrace,
          );
        } else if (error.message.contains('password')) {
          return AuthError.weakPassword(
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        break;
      case '401':
        return AuthError.invalidCredentials(
          originalError: error,
          stackTrace: stackTrace,
        );
      case '404':
        return AuthError.userNotFound(
          originalError: error,
          stackTrace: stackTrace,
        );
      case '422':
        if (error.message.contains('Email not confirmed')) {
          return AuthError.emailNotVerified(
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        break;
    }

    // Default auth error
    return AuthError(
      message: error.message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  // Helper to show error snackbar
  static void showErrorSnackBar(
      BuildContext context, dynamic error, Language language) {
    String errorMessage;

    if (error is AppError) {
      errorMessage = ErrorLocalizer.localizeError(error.message, language);
      AppLogger().logDebug('Showing error snackbar: $errorMessage');
    } else {
      errorMessage = ErrorLocalizer.localizeError(
        'An error occurred. Please try again',
        language,
      );
      AppLogger().logWarning(
          'Showing generic error snackbar for unhandled error: $error');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: language == Language.korean ? '확인' : 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
