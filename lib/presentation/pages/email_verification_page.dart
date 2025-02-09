import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/core/services/auth_service.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:erp/presentation/pages/sign_page.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Verify email code
  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final language =
        ref.read(languageProvider) == Language.korean ? 'ko' : 'en';

    final result = await AuthService().verifyEmail(
      email: widget.email,
      token: _codeController.text.trim(),
      language: language,
    );

    setState(() {
      _isLoading = false;

      if (result['success']) {
        _successMessage = result['message'];
      } else {
        _errorMessage = result['message'];
      }
    });

    if (result['success']) {
      // Delay to show success message before navigating
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignPage()),
            (route) => false,
          );
        }
      });
    }
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final language =
        ref.read(languageProvider) == Language.korean ? 'ko' : 'en';

    final result = await AuthService().resendVerificationEmail(
      email: widget.email,
      language: language,
    );

    setState(() {
      _isLoading = false;

      if (result['success']) {
        _successMessage = result['message'];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  // 네트워크 연결 확인 함수
  Future<bool> _isNetworkConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '이메일 인증' : 'Email Verification'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  isKorean
                      ? '인증 이메일이 ${widget.email}로 전송되었습니다.'
                      : 'A verification email has been sent to ${widget.email}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  isKorean
                      ? '받은 인증 코드를 아래에 입력해 주세요.'
                      : 'Please enter the verification code below.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: isKorean ? '인증 코드' : 'Verification Code',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.security),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isKorean
                          ? '인증 코드를 입력해 주세요.'
                          : 'Please enter verification code.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isKorean ? '인증하기' : 'Verify'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _resendVerificationEmail,
                  child: Text(
                      isKorean ? '인증 코드 재전송하기' : 'Resend verification code'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
