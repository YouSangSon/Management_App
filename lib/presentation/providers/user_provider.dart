import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/domain/models/user_info.dart';
import 'package:erp/data/repositories/cloud/user_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final supabase = Supabase.instance.client;
  return UserRepositoryImpl(supabase);
});

final currentUserProvider = FutureProvider<UserInfo?>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getCurrentUser();
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserInfo?>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserProfileNotifier(userRepository);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserInfo?>> {
  final UserRepositoryImpl _userRepository;

  UserProfileNotifier(this._userRepository)
      : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final userInfo = await _userRepository.getCurrentUser();
      state = AsyncValue.data(userInfo);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    DateTime? birthday,
    String? avatarUrl,
  }) async {
    try {
      await _userRepository.updateUserProfile(
        username: username,
        fullName: fullName,
        birthday: birthday,
        avatarUrl: avatarUrl,
      );

      // Reload profile after update
      await loadUserProfile();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
