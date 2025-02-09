import 'package:erp/domain/models/user_info.dart';

abstract class UserRepository {
  Future<UserInfo?> getCurrentUser();
  Future<UserInfo?> getUserById(String id);
  Future<void> updateUserProfile({
    String? username,
    String? fullName,
    DateTime? birthday,
    String? avatarUrl,
  });
}
