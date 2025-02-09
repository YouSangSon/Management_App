
class UserInfo {
  final String id;
  final String email;
  final String? avatarUrl;
  final String? username;
  final String? fullName;
  final DateTime? birthday;
  final bool isAdmin;
  final DateTime createdAt;

  UserInfo({
    required this.id,
    required this.email,
    this.avatarUrl,
    this.username,
    this.fullName,
    this.birthday,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      username: json['username'],
      fullName: json['full_name'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      isAdmin: json['admin'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'avatar_url': avatarUrl,
      'username': username,
      'full_name': fullName,
      'birthday': birthday?.toIso8601String(),
      'admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserInfo copyWith({
    String? id,
    String? email,
    String? avatarUrl,
    String? username,
    String? fullName,
    DateTime? birthday,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      birthday: birthday ?? this.birthday,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
