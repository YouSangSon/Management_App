import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:erp/core/services/email_service.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final EmailService _emailService;

  // Supabase Client
  SupabaseClient get _supabase => Supabase.instance.client;

  // Singleton pattern
  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _emailService = EmailService();
  }

  // Get current user ID if logged in
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Hash password
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate random salt
  String _generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Register a new user with email verification
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? language,
  }) async {
    try {
      AppLogger().logInfo('=== REGISTER FUNCTION CALLED ===');
      AppLogger().logInfo('Email: $email, Username: $username');

      // Check if email already exists
      final existingUsers =
          await _supabase.from('users').select().eq('email', email);

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이미 등록된 이메일 주소입니다.'
              : 'Email address is already registered.',
        };
      }

      // Check if username already exists
      final existingUsernames =
          await _supabase.from('users').select().eq('username', username);

      if (existingUsernames.isNotEmpty) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이미 사용 중인 사용자 이름입니다.'
              : 'Username is already taken.',
        };
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);

      // Create a pending user record
      try {
        // PostgreSQL 정책 우회를 위해 직접 SQL 실행
        final result = await _supabase.rpc('create_new_user', params: {
          'p_email': email,
          'p_username': username,
          'p_full_name': fullName,
          'p_password_hash': hashedPassword,
          'p_salt': salt,
          'p_is_verified': false,
        });

        AppLogger().logInfo('User record created via RPC: $result');
      } catch (e) {
        AppLogger()
            .logError(e, context: 'Creating user via RPC: ${e.toString()}');
        throw e; // 다시 던져서 상위 catch 블록에서 처리
      }

      // Supabase Auth에도 사용자 등록 시도 (선택적)
      try {
        // 원래 비밀번호로 Supabase Auth에 등록
        await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'username': username,
            'full_name': fullName,
          },
        );
        AppLogger().logInfo('Supabase Auth에 사용자 등록 성공: $email');
      } catch (e) {
        // Auth 등록 실패해도 커스텀 테이블에 사용자가 등록되었으므로 계속 진행
        AppLogger().logWarning('Supabase Auth 등록 실패: ${e.toString()}');
      }

      // Send verification email
      // AppLogger().logInfo('Attempting to send verification email to: $email');
      // final emailSent = await _emailService.sendVerificationEmail(
      //   email: email,
      //   username: username,
      //   language: language,
      // );

      // if (!emailSent) {
      //   AppLogger().logError('Failed to send verification email',
      //       context: 'AuthService.register');
      //   return {
      //     'success': false,
      //     'message': language == 'ko'
      //         ? '인증 이메일을 보내는 데 실패했습니다. 나중에 다시 시도해 주세요.'
      //         : 'Failed to send verification email. Please try again later.',
      //   };
      // }

      // AppLogger().logInfo('Verification email sent successfully to: $email');

      return {
        'success': true,
        'message': language == 'ko'
            ? '회원가입이 완료되었습니다. 이메일을 확인해 주세요.'
            : 'Registration successful. Please check your email for verification.',
        'needsVerification': true,
        'email': email,
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Registration error: ${e.toString()}');
      return {
        'success': false,
        'message': language == 'ko'
            ? '회원가입 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during registration. Please try again later.',
        'error': e.toString(),
      };
    }
  }

  // Verify email with token
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String token,
    String? language,
  }) async {
    try {
      final isValid = _emailService.verifyEmail(email, token);

      if (!isValid) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '인증 코드가 유효하지 않거나 만료되었습니다.'
              : 'Invalid or expired verification code.',
        };
      }

      // Update user record to verified
      await _supabase
          .from('users')
          .update({'is_verified': true}).eq('email', email);

      return {
        'success': true,
        'message': language == 'ko'
            ? '이메일 인증이 완료되었습니다. 이제 로그인할 수 있습니다.'
            : 'Email verification successful. You can now log in.',
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Email verification error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '이메일 인증 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during email verification. Please try again later.',
      };
    }
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
    String? language,
  }) async {
    try {
      // Check if user exists and is not already verified
      final users = await _supabase.from('users').select().eq('email', email);

      if (users.isEmpty) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '등록되지 않은 이메일 주소입니다.'
              : 'Email address is not registered.',
        };
      }

      final user = users[0];

      if (user['is_verified'] == true) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이미 인증된 이메일 주소입니다.'
              : 'Email address is already verified.',
        };
      }

      // Send verification email
      final emailSent = await _emailService.sendVerificationEmail(
        email: email,
        username: user['username'],
        language: language,
      );

      if (!emailSent) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '인증 이메일을 보내는 데 실패했습니다. 나중에 다시 시도해 주세요.'
              : 'Failed to send verification email. Please try again later.',
        };
      }

      return {
        'success': true,
        'message': language == 'ko'
            ? '인증 이메일이 다시 전송되었습니다. 이메일을 확인해 주세요.'
            : 'Verification email has been resent. Please check your email.',
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Resend verification email error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '인증 이메일 재전송 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred while resending the verification email. Please try again later.',
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? language,
  }) async {
    try {
      // Get user from database
      final users = await _supabase.from('users').select().eq('email', email);

      if (users.isEmpty) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이메일 또는 비밀번호가 올바르지 않습니다.'
              : 'Invalid email or password.',
        };
      }

      final user = users[0];

      // Check if email is verified
      if (user['is_verified'] != true) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이메일 인증이 필요합니다. 인증 이메일을 확인해 주세요.'
              : 'Email verification required. Please check your verification email.',
          'needsVerification': true,
          'email': email,
        };
      }

      // Verify password
      final salt = user['salt'];
      final hashedPassword = _hashPassword(password, salt);

      if (hashedPassword != user['password_hash']) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이메일 또는 비밀번호가 올바르지 않습니다.'
              : 'Invalid email or password.',
        };
      }

      // Supabase 인증 시스템 사용 (선택적)
      try {
        // 해시된 비밀번호가 아닌 원래 비밀번호 사용
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password, // 원래 비밀번호 사용
        );
      } catch (e) {
        // Supabase 인증 실패 시 사용자 정의 세션 사용
        AppLogger().logWarning(
          'Supabase Auth 로그인 실패: ${e.toString()}. 사용자 정의 세션을 사용합니다.',
        );

        // 추가 로직: 필요한 경우 사용자 정의 세션 생성
      }

      return {
        'success': true,
        'message': language == 'ko' ? '로그인 성공!' : 'Login successful!',
        'user': {
          'id': user['id'],
          'email': user['email'],
          'username': user['username'],
          'fullName': user['full_name'],
        },
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Login error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '로그인 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during login. Please try again later.',
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout({String? language}) async {
    try {
      await _supabase.auth.signOut();

      return {
        'success': true,
        'message':
            language == 'ko' ? '로그아웃 되었습니다.' : 'You have been logged out.',
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Logout error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '로그아웃 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during logout. Please try again later.',
      };
    }
  }

  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
    String? language,
  }) async {
    try {
      // Check if user exists
      final users = await _supabase.from('users').select().eq('email', email);

      if (users.isEmpty) {
        // Don't reveal if email exists or not for security
        return {
          'success': true,
          'message': language == 'ko'
              ? '비밀번호 재설정 이메일을 발송했습니다. 이메일을 확인해 주세요.'
              : 'If your email is registered, you will receive a password reset email shortly.',
        };
      }

      final user = users[0];

      // Send password reset email
      final emailSent = await _emailService.sendPasswordResetEmail(
        email: email,
        username: user['username'],
        language: language,
      );

      if (!emailSent) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '비밀번호 재설정 이메일을 보내는 데 실패했습니다. 나중에 다시 시도해 주세요.'
              : 'Failed to send password reset email. Please try again later.',
        };
      }

      return {
        'success': true,
        'message': language == 'ko'
            ? '비밀번호 재설정 이메일을 발송했습니다. 이메일을 확인해 주세요.'
            : 'Password reset email has been sent. Please check your email.',
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Password reset request error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '비밀번호 재설정 요청 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during password reset request. Please try again later.',
      };
    }
  }

  // Verify password reset token
  Future<Map<String, dynamic>> verifyPasswordResetToken({
    required String email,
    required String token,
    String? language,
  }) async {
    try {
      final isValid = _emailService.verifyPasswordResetToken(email, token);

      if (!isValid) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '유효하지 않거나 만료된 비밀번호 재설정 코드입니다.'
              : 'Invalid or expired password reset code.',
        };
      }

      return {
        'success': true,
        'message': language == 'ko'
            ? '코드가 확인되었습니다. 이제 새 비밀번호를 설정할 수 있습니다.'
            : 'Code verified. You can now set a new password.',
      };
    } catch (e) {
      AppLogger()
          .logError(e, context: 'Password reset token verification error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '비밀번호 재설정 코드 확인 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during password reset code verification. Please try again later.',
      };
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    String? language,
  }) async {
    try {
      final isValid = _emailService.verifyPasswordResetToken(email, token);

      if (!isValid) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '유효하지 않거나 만료된 비밀번호 재설정 코드입니다.'
              : 'Invalid or expired password reset code.',
        };
      }

      // Get user from database
      final users = await _supabase.from('users').select().eq('email', email);

      if (users.isEmpty) {
        return {
          'success': false,
          'message': language == 'ko' ? '사용자를 찾을 수 없습니다.' : 'User not found.',
        };
      }

      // Generate new salt and hash new password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);

      // Update user record with new password
      await _supabase.from('users').update({
        'password_hash': hashedPassword,
        'salt': salt,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('email', email);

      // Consume token so it can't be used again
      _emailService.consumePasswordResetToken(email);

      return {
        'success': true,
        'message': language == 'ko'
            ? '비밀번호가 성공적으로 재설정되었습니다. 이제 새 비밀번호로 로그인할 수 있습니다.'
            : 'Password has been reset successfully. You can now log in with your new password.',
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Password reset error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '비밀번호 재설정 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred during password reset. Please try again later.',
      };
    }
  }

  // Find email by username or full name
  Future<Map<String, dynamic>> findEmail({
    String? username,
    String? fullName,
    String? language,
  }) async {
    try {
      if ((username == null || username.isEmpty) &&
          (fullName == null || fullName.isEmpty)) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '사용자 이름 또는 실명을 입력해 주세요.'
              : 'Please enter a username or full name.',
        };
      }

      List users = [];

      // Search by username
      if (username != null && username.isNotEmpty) {
        final usernameResults =
            await _supabase.from('users').select().eq('username', username);

        if (usernameResults.isNotEmpty) {
          users = usernameResults;
        }
      }

      // If not found by username, search by full name
      if (users.isEmpty && fullName != null && fullName.isNotEmpty) {
        final fullNameResults = await _supabase
            .from('users')
            .select()
            .ilike('full_name', '%$fullName%');

        if (fullNameResults.isNotEmpty) {
          users = fullNameResults;
        }
      }

      if (users.isEmpty) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '일치하는 계정을 찾을 수 없습니다.'
              : 'No matching account found.',
        };
      }

      final user = users[0];

      // Send email reminder email
      final emailSent = await _emailService.sendEmailReminderEmail(
        email: user['email'],
        username: user['username'],
        language: language,
      );

      if (!emailSent) {
        return {
          'success': false,
          'message': language == 'ko'
              ? '이메일 정보를 보내는 데 실패했습니다. 나중에 다시 시도해 주세요.'
              : 'Failed to send email information. Please try again later.',
        };
      }

      // Mask email for privacy
      final email = user['email'];
      final maskedEmail = _maskEmail(email);

      return {
        'success': true,
        'message': language == 'ko'
            ? '이메일 정보를 찾았습니다. 전체 이메일 주소가 포함된 알림 메일이 $maskedEmail로 전송되었습니다.'
            : 'Email information found. A notification with your full email address has been sent to $maskedEmail.',
        'maskedEmail': maskedEmail,
      };
    } catch (e) {
      AppLogger().logError(e, context: 'Find email error');
      return {
        'success': false,
        'message': language == 'ko'
            ? '이메일 찾기 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.'
            : 'An error occurred while finding email. Please try again later.',
      };
    }
  }

  // Mask email address for privacy
  String _maskEmail(String email) {
    try {
      final parts = email.split('@');
      if (parts.length != 2) return email;

      final name = parts[0];
      final domain = parts[1];

      String maskedName;
      if (name.length <= 2) {
        maskedName = '${name[0]}*';
      } else {
        maskedName = name[0] + '*' * (name.length - 2) + name[name.length - 1];
      }

      return '$maskedName@$domain';
    } catch (e) {
      // In case of any error, return a generic masked email
      return email.contains('@')
          ? '${email.split('@')[0][0]}***@${email.split('@')[1]}'
          : email;
    }
  }

  // Initialize and clean up expired tokens
  void initialize() {
    _emailService.cleanupExpiredTokens();
  }
}
