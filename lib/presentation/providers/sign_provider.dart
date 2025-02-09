import 'package:erp/core/errors/error_handler.dart';
import 'package:erp/core/errors/error_model.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:erp/data/repositories/cloud/sign_repository.dart';
import 'package:erp/domain/usecases/sign_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/core/services/auth_service.dart';

enum SignMode { signIn, signUp }

// Providers that switch SignMode
final signModeProvider = StateProvider<SignMode>((ref) => SignMode.signIn);

// Provider that provides SignController
final signProvider =
    StateNotifierProvider<SignController, AsyncValue<void>>((ref) {
  final supabase = Supabase.instance.client;
  final signRepository = SignRepositoryImpl(supabase);
  final signUseCase = SignUseCase(signRepository);

  return SignController(signUseCase);
});

class SignController extends StateNotifier<AsyncValue<void>> {
  final SignUseCase signUseCase;
  final AppLogger _logger = AppLogger();
  final AuthService _authService = AuthService();

  SignController(this.signUseCase) : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      _logger.logInfo('SignController: Attempting sign in for $email');
      await signUseCase.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
      _logger.logInfo('SignController: Sign in successful for $email');
    } catch (e, st) {
      _logger.logError(e, stackTrace: st, context: 'SignController.signIn');
      if (e is AppError) {
        state = AsyncValue.error(e, st);
      } else {
        // Convert to AppError if it isn't already
        final errorHandler = ErrorHandler();
        final appError = errorHandler.handleException(
          e,
          stackTrace: st,
          context: 'SignController.signIn',
        );
        state = AsyncValue.error(appError, st);
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      _logger.logInfo('SignController: Attempting sign up for $email');

      final language =
          WidgetsBinding.instance.window.locale.languageCode == 'ko'
              ? 'ko'
              : 'en';
      final registerResult = await _authService.register(
        email: email,
        password: password,
        username: username ?? email.split('@')[0],
        fullName: fullName ?? '',
        language: language,
      );

      if (!registerResult['success']) {
        throw AuthError(
          message: registerResult['message'] ?? '회원가입에 실패했습니다.',
          originalError: registerResult,
        );
      }

      _logger.logInfo(
          'SignController: Register successful via AuthService for $email');
      state = const AsyncValue.data(null);
      _logger.logInfo('SignController: Sign up successful for $email');
    } catch (e, st) {
      _logger.logError(e, stackTrace: st, context: 'SignController.signUp');
      if (e is AppError) {
        state = AsyncValue.error(e, st);
      } else {
        // Convert to AppError if it isn't already
        final errorHandler = ErrorHandler();
        final appError = errorHandler.handleException(
          e,
          stackTrace: st,
          context: 'SignController.signUp',
        );
        state = AsyncValue.error(appError, st);
      }
    }
  }

  // Method to check if the user is confirmed
  Future<bool> isUserConfirmed() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        return currentUser.emailConfirmedAt != null;
      }
      return false;
    } catch (e, st) {
      _logger.logError(e,
          stackTrace: st, context: 'SignController.isUserConfirmed');
      return false;
    }
  }

  // Method to resend confirmation email
  Future<void> resendConfirmationEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      _logger.logInfo('SignController: Resending confirmation email to $email');
      await signUseCase.resendConfirmationEmail(email);
      state = const AsyncValue.data(null);
      _logger.logInfo('SignController: Confirmation email resent to $email');
    } catch (e, st) {
      _logger.logError(e,
          stackTrace: st, context: 'SignController.resendConfirmationEmail');
      if (e is AppError) {
        state = AsyncValue.error(e, st);
      } else {
        // Convert to AppError if it isn't already
        final errorHandler = ErrorHandler();
        final appError = errorHandler.handleException(
          e,
          stackTrace: st,
          context: 'SignController.resendConfirmationEmail',
        );
        state = AsyncValue.error(appError, st);
      }
    }
  }
}
