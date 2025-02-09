abstract class SignRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  });
  Future<void> resetPassword(String email);
  Future<void> resendConfirmationEmail(String email);
}
