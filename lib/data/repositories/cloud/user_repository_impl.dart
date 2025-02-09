import 'package:erp/domain/models/user_info.dart';
import 'package:erp/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient supabase;

  UserRepositoryImpl(this.supabase);

  @override
  Future<UserInfo?> getCurrentUser() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return null;

    final response = await supabase
        .from('userInfo')
        .select()
        .eq('id', currentUser.id)
        .single();
    return UserInfo.fromJson(response);
  }

  @override
  Future<UserInfo?> getUserById(String id) async {
    final response =
        await supabase.from('userInfo').select().eq('id', id).single();
    return UserInfo.fromJson(response);
  }

  @override
  Future<void> updateUserProfile({
    String? username,
    String? fullName,
    DateTime? birthday,
    String? avatarUrl,
  }) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Not authenticated');
    }

    final updates = {
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (birthday != null)
        'birthday': birthday.toIso8601String().split('T')[0],
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    if (updates.isEmpty) return;

    await supabase.from('userInfo').update(updates).eq('id', currentUser.id);
  }
}
