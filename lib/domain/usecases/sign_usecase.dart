import 'package:erp/core/utils/logger.dart';
import 'package:erp/domain/repositories/sign_repository.dart';

class SignUseCase {
  final SignRepository repository;
  final AppLogger _logger = AppLogger();

  SignUseCase(this.repository);

  Future<void> signIn({required String email, required String password}) async {
    _logger.logInfo('SignUseCase: Executing signIn for $email');
    return repository.signIn(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  }) async {
    _logger.logInfo('SignUseCase: Executing signUp for $email');
    return repository.signUp(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );
  }

  Future<void> resetPassword(String email) async {
    _logger.logInfo('SignUseCase: Executing resetPassword for $email');
    return repository.resetPassword(email);
  }

  Future<void> resendConfirmationEmail(String email) async {
    _logger
        .logInfo('SignUseCase: Executing resendConfirmationEmail for $email');
    return repository.resendConfirmationEmail(email);
  }
}
