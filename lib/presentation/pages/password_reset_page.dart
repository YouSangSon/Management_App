import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/core/services/auth_service.dart';
import 'package:erp/presentation/providers/language_provider.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  final String email;

  const PasswordResetPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCodeVerified = false;
  String? _errorMessage;
  String? _successMessage;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Verify the reset code
  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final language =
        ref.read(languageProvider) == Language.korean ? 'ko' : 'en';

    final result = await AuthService().verifyPasswordResetToken(
      email: widget.email,
      token: _codeController.text.trim(),
      language: language,
    );

    setState(() {
      _isLoading = false;

      if (result['success']) {
        _isCodeVerified = true;
        _successMessage = result['message'];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  // Reset password with new password
  Future<void> _resetPassword() async {
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

    final result = await AuthService().resetPassword(
      email: widget.email,
      token: _codeController.text.trim(),
      newPassword: _passwordController.text,
      language: language,
    );

    setState(() {
      _isLoading = false;

      if (result['success']) {
        _successMessage = result['message'];
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Navigate back to login after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '비밀번호 재설정' : 'Reset Password'),
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
                  _isCodeVerified ? Icons.lock_open : Icons.pin,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  _isCodeVerified
                      ? (isKorean
                          ? '새 비밀번호를 설정해 주세요.'
                          : 'Set your new password.')
                      : (isKorean
                          ? '이메일로 전송된 인증 코드를 입력해 주세요.'
                          : 'Enter the verification code sent to your email.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Verification code field
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: isKorean ? '인증 코드' : 'Verification Code',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.password),
                  ),
                  enabled: !_isCodeVerified,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isKorean
                          ? '인증 코드를 입력해 주세요.'
                          : 'Please enter the verification code.';
                    }
                    return null;
                  },
                ),

                if (!_isCodeVerified) ...[
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
                        : Text(isKorean ? '코드 확인' : 'Verify Code'),
                  ),
                ],

                // New password fields (shown after code verification)
                if (_isCodeVerified) ...[
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: isKorean ? '새 비밀번호' : 'New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isKorean
                            ? '새 비밀번호를 입력해 주세요.'
                            : 'Please enter a new password.';
                      }
                      if (value.length < 8) {
                        return isKorean
                            ? '비밀번호는 8자 이상이어야 합니다.'
                            : 'Password must be at least 8 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: isKorean ? '비밀번호 확인' : 'Confirm Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isKorean
                            ? '비밀번호를 다시 입력해 주세요.'
                            : 'Please confirm your password.';
                      }
                      if (value != _passwordController.text) {
                        return isKorean
                            ? '비밀번호가 일치하지 않습니다.'
                            : 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isKorean ? '비밀번호 변경' : 'Change Password'),
                  ),
                ],

                // Messages
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
