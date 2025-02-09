import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'package:erp/core/utils/logger.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();

  // SMTP 설정
  late final String _smtpUsername;
  late final String _smtpPassword;
  late final String _smtpHost;
  late final int _smtpPort;
  late final bool _smtpSecure;
  late final String _fromName;

  // 토큰 관리
  final Map<String, _TokenInfo> _verificationTokens = {};
  final Map<String, _TokenInfo> _passwordResetTokens = {};

  // 싱글톤 패턴
  factory EmailService() {
    return _instance;
  }

  EmailService._internal() {
    _initializeFromEnv();
  }

  void _initializeFromEnv() {
    _smtpUsername = dotenv.env['SMTP_USERNAME'] ?? '';
    _smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
    _smtpHost = dotenv.env['SMTP_HOST'] ?? 'smtp.gmail.com';
    _smtpPort = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587') ?? 587;
    _smtpSecure = (dotenv.env['SMTP_SECURE'] ?? 'true').toLowerCase() == 'true';
    _fromName = dotenv.env['EMAIL_FROM_NAME'] ?? 'Management System';

    if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
      AppLogger()
          .logWarning('SMTP credentials not properly configured in .env file');
    }
  }

  // SMTP 서버 객체 생성
  SmtpServer _getSmtpServer() {
    return SmtpServer(
      _smtpHost,
      port: _smtpPort,
      ssl: _smtpSecure,
      username: _smtpUsername,
      password: _smtpPassword,
    );
  }

  // 이메일 전송 공통 메서드
  Future<bool> _sendEmail({
    required String to,
    required String subject,
    required String text,
    String? html,
  }) async {
    try {
      AppLogger().logInfo('===== 이메일 전송 시작 =====');
      AppLogger().logInfo('수신자: $to');
      AppLogger().logInfo('제목: $subject');
      AppLogger().logInfo('SMTP 설정:');
      AppLogger().logInfo('  호스트: $_smtpHost');
      AppLogger().logInfo('  포트: $_smtpPort');
      AppLogger().logInfo('  보안: $_smtpSecure');
      AppLogger().logInfo('  계정: $_smtpUsername');

      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        AppLogger().logError('SMTP 계정 정보가 비어 있습니다!', context: '이메일 서비스');
        return false;
      }

      final smtpServer = _getSmtpServer();

      final message = Message()
        ..from = Address(_smtpUsername, _fromName)
        ..recipients.add(to)
        ..subject = subject
        ..text = text;

      if (html != null) {
        message.html = html;
      }

      AppLogger().logInfo('이메일 전송 중...');
      final sendReport = await send(message, smtpServer);
      AppLogger().logInfo('이메일 전송 완료: ${sendReport.toString()}');
      AppLogger().logInfo('===== 이메일 전송 완료 =====');
      return true;
    } catch (e) {
      AppLogger().logError(e, context: '이메일 전송 실패: ${e.toString()}');
      AppLogger().logInfo('===== 이메일 전송 실패 =====');
      return false;
    }
  }

  // 유니크한 토큰 생성
  String _generateToken(String email, [int length = 32]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = randomAlphaNumeric(8);
    final baseString = '$email:$timestamp:$random';
    final bytes = utf8.encode(baseString);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, length);
  }

  // 이메일 확인 토큰 생성 및 이메일 전송
  Future<bool> sendVerificationEmail({
    required String email,
    required String username,
    String? language,
  }) async {
    final token = _generateToken(email);
    final expiryTime = DateTime.now().add(const Duration(hours: 24));

    _verificationTokens[email] = _TokenInfo(
      token: token,
      expiry: expiryTime,
      username: username,
    );

    final isKorean = language == 'ko';

    final subject = isKorean ? '이메일 주소 확인' : 'Verify Your Email Address';

    final text = isKorean
        ? '안녕하세요 $username님,\n\n'
            '귀하의 이메일 주소 확인을 위해 아래 코드를 입력해 주세요:\n\n'
            '$token\n\n'
            '이 코드는 24시간 동안 유효합니다.\n\n'
            '감사합니다,\n'
            '관리 시스템 팀'
        : 'Hello $username,\n\n'
            'Please enter the following code to verify your email address:\n\n'
            '$token\n\n'
            'This code is valid for 24 hours.\n\n'
            'Thank you,\n'
            'Management System Team';

    final html = isKorean
        ? '<p>안녕하세요 <strong>$username</strong>님,</p>'
            '<p>귀하의 이메일 주소 확인을 위해 아래 코드를 입력해 주세요:</p>'
            '<h2 style="background-color: #f5f5f5; padding: 10px; text-align: center; font-family: monospace;">$token</h2>'
            '<p>이 코드는 24시간 동안 유효합니다.</p>'
            '<p>감사합니다,<br>관리 시스템 팀</p>'
        : '<p>Hello <strong>$username</strong>,</p>'
            '<p>Please enter the following code to verify your email address:</p>'
            '<h2 style="background-color: #f5f5f5; padding: 10px; text-align: center; font-family: monospace;">$token</h2>'
            '<p>This code is valid for 24 hours.</p>'
            '<p>Thank you,<br>Management System Team</p>';

    return await _sendEmail(
      to: email,
      subject: subject,
      text: text,
      html: html,
    );
  }

  // 이메일 확인 토큰 검증
  bool verifyEmail(String email, String token) {
    final tokenInfo = _verificationTokens[email];
    if (tokenInfo == null) {
      return false;
    }

    if (DateTime.now().isAfter(tokenInfo.expiry)) {
      _verificationTokens.remove(email);
      return false;
    }

    if (tokenInfo.token != token) {
      return false;
    }

    _verificationTokens.remove(email);
    return true;
  }

  // 비밀번호 재설정 이메일 전송
  Future<bool> sendPasswordResetEmail({
    required String email,
    String? username,
    String? language,
  }) async {
    // 이메일이 등록되어 있는지 확인하는 로직 필요

    final token = _generateToken(email);
    final expiryTime = DateTime.now().add(const Duration(hours: 1));

    _passwordResetTokens[email] = _TokenInfo(
      token: token,
      expiry: expiryTime,
      username: username,
    );

    final isKorean = language == 'ko';
    final displayName = username ?? email;

    final subject = isKorean ? '비밀번호 재설정' : 'Password Reset';

    final text = isKorean
        ? '안녕하세요 $displayName님,\n\n'
            '귀하의 비밀번호 재설정을 위해 아래 코드를 입력해 주세요:\n\n'
            '$token\n\n'
            '이 코드는 1시간 동안 유효합니다.\n\n'
            '본인이 요청하지 않았다면 이 이메일을 무시하세요.\n\n'
            '감사합니다,\n'
            '관리 시스템 팀'
        : 'Hello $displayName,\n\n'
            'Please enter the following code to reset your password:\n\n'
            '$token\n\n'
            'This code is valid for 1 hour.\n\n'
            'If you did not request this, please ignore this email.\n\n'
            'Thank you,\n'
            'Management System Team';

    final html = isKorean
        ? '<p>안녕하세요 <strong>$displayName</strong>님,</p>'
            '<p>귀하의 비밀번호 재설정을 위해 아래 코드를 입력해 주세요:</p>'
            '<h2 style="background-color: #f5f5f5; padding: 10px; text-align: center; font-family: monospace;">$token</h2>'
            '<p>이 코드는 1시간 동안 유효합니다.</p>'
            '<p>본인이 요청하지 않았다면 이 이메일을 무시하세요.</p>'
            '<p>감사합니다,<br>관리 시스템 팀</p>'
        : '<p>Hello <strong>$displayName</strong>,</p>'
            '<p>Please enter the following code to reset your password:</p>'
            '<h2 style="background-color: #f5f5f5; padding: 10px; text-align: center; font-family: monospace;">$token</h2>'
            '<p>This code is valid for 1 hour.</p>'
            '<p>If you did not request this, please ignore this email.</p>'
            '<p>Thank you,<br>Management System Team</p>';

    return await _sendEmail(
      to: email,
      subject: subject,
      text: text,
      html: html,
    );
  }

  // 비밀번호 재설정 토큰 검증
  bool verifyPasswordResetToken(String email, String token) {
    final tokenInfo = _passwordResetTokens[email];
    if (tokenInfo == null) {
      return false;
    }

    if (DateTime.now().isAfter(tokenInfo.expiry)) {
      _passwordResetTokens.remove(email);
      return false;
    }

    if (tokenInfo.token != token) {
      return false;
    }

    return true;
  }

  // 비밀번호 재설정 토큰 소비 (비밀번호 변경 후)
  void consumePasswordResetToken(String email) {
    _passwordResetTokens.remove(email);
  }

  // 이메일 찾기 이메일 전송 (사용자 정보가 맞으면 해당 이메일로 알림)
  Future<bool> sendEmailReminderEmail({
    required String email,
    required String username,
    String? language,
  }) async {
    final isKorean = language == 'ko';

    final subject = isKorean ? '이메일 계정 정보' : 'Your Email Account Information';

    final text = isKorean
        ? '안녕하세요 $username님,\n\n'
            '귀하의 계정 정보 요청에 대한 안내입니다.\n\n'
            '귀하의 등록된 이메일 주소는 다음과 같습니다:\n'
            '$email\n\n'
            '본인이 요청하지 않았다면 즉시 비밀번호를 변경해 주세요.\n\n'
            '감사합니다,\n'
            '관리 시스템 팀'
        : 'Hello $username,\n\n'
            'This is a notification regarding your account information request.\n\n'
            'Your registered email address is:\n'
            '$email\n\n'
            'If you did not request this information, please change your password immediately.\n\n'
            'Thank you,\n'
            'Management System Team';

    final html = isKorean
        ? '<p>안녕하세요 <strong>$username</strong>님,</p>'
            '<p>귀하의 계정 정보 요청에 대한 안내입니다.</p>'
            '<p>귀하의 등록된 이메일 주소는 다음과 같습니다:</p>'
            '<h3 style="background-color: #f5f5f5; padding: 10px; text-align: center;">$email</h3>'
            '<p>본인이 요청하지 않았다면 즉시 비밀번호를 변경해 주세요.</p>'
            '<p>감사합니다,<br>관리 시스템 팀</p>'
        : '<p>Hello <strong>$username</strong>,</p>'
            '<p>This is a notification regarding your account information request.</p>'
            '<p>Your registered email address is:</p>'
            '<h3 style="background-color: #f5f5f5; padding: 10px; text-align: center;">$email</h3>'
            '<p>If you did not request this information, please change your password immediately.</p>'
            '<p>Thank you,<br>Management System Team</p>';

    return await _sendEmail(
      to: email,
      subject: subject,
      text: text,
      html: html,
    );
  }

  // 정기적으로 만료된 토큰 정리 (앱 시작 시 호출할 수 있음)
  void cleanupExpiredTokens() {
    final now = DateTime.now();

    _verificationTokens.removeWhere((email, info) => now.isAfter(info.expiry));
    _passwordResetTokens.removeWhere((email, info) => now.isAfter(info.expiry));

    AppLogger().logInfo('Expired tokens cleaned up');
  }
}

// 토큰 정보를 저장하는 내부 클래스
class _TokenInfo {
  final String token;
  final DateTime expiry;
  final String? username;

  _TokenInfo({
    required this.token,
    required this.expiry,
    this.username,
  });
}
