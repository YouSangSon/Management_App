import 'package:erp/core/errors/error_handler.dart';
import 'package:erp/core/errors/error_model.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:erp/domain/repositories/sign_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignRepositoryImpl implements SignRepository {
  final SupabaseClient supabase;
  final ErrorHandler _errorHandler = ErrorHandler();
  final AppLogger _logger = AppLogger();

  SignRepositoryImpl(this.supabase);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      _logger.logInfo('Attempting to sign in user with email: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw AuthError.invalidCredentials();
      }

      _logger.logInfo('User signed in successfully: ${response.user?.email}');
    } catch (e, stackTrace) {
      final appError = _errorHandler.handleException(
        e,
        stackTrace: stackTrace,
        context: 'SignRepositoryImpl.signIn',
      );
      throw appError;
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  }) async {
    try {
      _logger.logInfo('Attempting to sign up user with email: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'name': fullName,
        },
      );

      if (response.user == null) {
        throw AuthError(
          message: 'Sign up failed. Please try again.',
          originalError: response,
        );
      }

      _logger.logInfo('User signed up successfully: ${response.user?.email}');
    } catch (e, stackTrace) {
      final appError = _errorHandler.handleException(
        e,
        stackTrace: stackTrace,
        context: 'SignRepositoryImpl.signUp',
      );
      throw appError;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      _logger.logInfo('Attempting to reset password for email: $email');

      await supabase.auth.resetPasswordForEmail(email);

      _logger.logInfo('Password reset email sent to: $email');
    } catch (e, stackTrace) {
      final appError = _errorHandler.handleException(
        e,
        stackTrace: stackTrace,
        context: 'SignRepositoryImpl.resetPassword',
      );
      throw appError;
    }
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      _logger.logInfo('Attempting to resend confirmation email to: $email');

      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      _logger.logInfo('Confirmation email resent to: $email');
    } catch (e, stackTrace) {
      final appError = _errorHandler.handleException(
        e,
        stackTrace: stackTrace,
        context: 'SignRepositoryImpl.resendConfirmationEmail',
      );
      throw appError;
    }
  }
}
