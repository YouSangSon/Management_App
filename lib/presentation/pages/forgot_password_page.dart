import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      setState(() {
        _isSuccess = true;
        _message = ref.read(languageProvider) == Language.korean
            ? '비밀번호 재설정 링크가 이메일로 전송되었습니다.'
            : 'Password reset link has been sent to your email.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '비밀번호 찾기' : 'Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 500 : double.infinity,
            ),
            child: Card(
              elevation: isLargeScreen ? 4 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isKorean ? '비밀번호 재설정' : 'Reset Your Password',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isKorean
                            ? '가입한 이메일을 입력하시면 비밀번호 재설정 링크를 보내드립니다.'
                            : 'Enter your email and we\'ll send you a password reset link.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: isKorean ? '이메일' : 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isKorean
                                ? '이메일을 입력하세요'
                                : 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return isKorean
                                ? '유효한 이메일을 입력하세요'
                                : 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(isKorean
                                  ? '비밀번호 재설정 링크 받기'
                                  : 'Send Reset Link'),
                            ),
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message!,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                            isKorean ? '로그인 화면으로 돌아가기' : 'Back to Sign In'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
