import 'package:erp/core/errors/error_model.dart';
import 'package:erp/presentation/providers/sign_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:erp/presentation/pages/privacy_policy_page.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:erp/presentation/pages/forgot_password_page.dart';
import 'package:erp/presentation/pages/email_confirmation_page.dart';
import 'package:erp/presentation/pages/find_email_page.dart';
import 'package:erp/presentation/pages/email_verification_page.dart';
import 'package:erp/core/errors/error_localizer.dart';
import 'package:erp/core/errors/error_handler.dart';
import 'package:erp/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignPage extends ConsumerStatefulWidget {
  const SignPage({super.key});

  @override
  ConsumerState<SignPage> createState() => _SignPageState();
}

class _SignPageState extends ConsumerState<SignPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreedToTOS = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // 이미 로그인되어 있으면 대시보드로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });

    // 상태 변경을 리스닝하여 로그인 성공 시 대시보드로 이동
    ref.listenManual(signProvider, (previous, next) {
      if (previous?.isLoading == true &&
          next?.isLoading == false &&
          next?.hasError == false) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          AppLogger().logInfo('Login successful, navigating to dashboard');
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    });
  }

  void _checkAuthStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isKorean = ref.read(languageProvider) == Language.korean;

    if (!_formKey.currentState!.validate()) return;

    final signMode = ref.read(signModeProvider);
    if (signMode == SignMode.signUp) {
      if (!_agreedToTOS) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isKorean
                  ? '이용 약관 및 개인정보 처리방침에 동의해주세요'
                  : 'Please agree to the Terms of Service and Privacy Policy.',
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        final validationError = ValidationError(
          message: isKorean ? '비밀번호가 일치하지 않습니다' : 'Passwords do not match',
        );
        ErrorHandler.showErrorSnackBar(
          context,
          validationError,
          ref.read(languageProvider),
        );
        return;
      }
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (signMode == SignMode.signIn) {
      await ref
          .read(signProvider.notifier)
          .signIn(email: email, password: password);

      // 리스너에서 처리하므로 여기에서는 추가 작업이 필요 없음
    } else {
      final username = _usernameController.text.trim();
      final fullName = _fullNameController.text.trim();

      await ref.read(signProvider.notifier).signUp(
            email: email,
            password: password,
            username: username.isNotEmpty ? username : null,
            fullName: fullName.isNotEmpty ? fullName : null,
          );

      if (!mounted) return;

      // 회원가입 성공 후 자동 로그인하거나 이메일 확인 페이지로 이동
      final signState = ref.read(signProvider);
      if (signState is AsyncData) {
        // 회원가입 후 자동 로그인 시도
        await ref
            .read(signProvider.notifier)
            .signIn(email: email, password: password);
      }
    }
  }

  void _toggleAuthMode() {
    ref.read(signModeProvider.notifier).update(
          (state) =>
              state == SignMode.signIn ? SignMode.signUp : SignMode.signIn,
        );
  }

  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;
    final signMode = ref.watch(signModeProvider);
    final signState = ref.watch(signProvider);
    final isSignUp = signMode == SignMode.signUp;

    // Get screen size to make UI responsive
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '관리 시스템' : 'Management System'),
        actions: [
          TextButton.icon(
            icon: Image.asset(
              isKorean
                  ? 'assets/icons/united_states.jpg'
                  : 'assets/icons/korea.jpg',
              width: 24,
              height: 24,
            ),
            label: Text(isKorean ? 'English' : '한국어'),
            onPressed: () {
              final newLanguage = isKorean ? Language.english : Language.korean;
              ref.read(languageProvider.notifier).setLanguage(newLanguage);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 600 : double.infinity,
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
                        isSignUp
                            ? (isKorean ? '계정 생성' : 'Create an Account')
                            : (isKorean ? '로그인' : 'Sign In'),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isLargeScreen ? 24 : 16),
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
                      SizedBox(height: isLargeScreen ? 24 : 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: isKorean ? '비밀번호' : 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                                ? '비밀번호를 입력하세요'
                                : 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return isKorean
                                ? '비밀번호는 최소 6자 이상이어야 합니다'
                                : 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (!isSignUp) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FindEmailPage(),
                                  ),
                                );
                              },
                              child: Text(
                                isKorean ? '이메일 찾기' : 'Find Email',
                              ),
                            ),
                            Text('  |  '),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                isKorean ? '비밀번호 찾기' : 'Forgot Password',
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isSignUp) ...[
                        SizedBox(height: isLargeScreen ? 24 : 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText:
                                isKorean ? '비밀번호 확인' : 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_confirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isKorean
                                  ? '비밀번호 확인을 입력하세요'
                                  : 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return isKorean
                                  ? '비밀번호가 일치하지 않습니다'
                                  : 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isLargeScreen ? 24 : 16),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: isKorean ? '이름' : 'Full Name',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 24 : 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTOS,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTOS = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreedToTOS = !_agreedToTOS;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                          text: isKorean
                                              ? '이용 약관 및 개인정보 처리방침에 동의합니다 '
                                              : 'I agree to the '),
                                      TextSpan(
                                        text: isKorean
                                            ? '이용 약관 및 개인정보 처리방침'
                                            : 'Terms of Service and Privacy Policy',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showPrivacyPolicy,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: isLargeScreen ? 24 : 16),
                      signState.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(isSignUp
                                  ? (isKorean ? '가입하기' : 'Sign Up')
                                  : (isKorean ? '로그인' : 'Sign In')),
                            ),
                      SizedBox(height: isLargeScreen ? 16 : 8),
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(isSignUp
                            ? (isKorean
                                ? '이미 계정이 있으신가요? 로그인'
                                : 'Already have an account? Sign In')
                            : (isKorean
                                ? '계정이 없으신가요? 가입하기'
                                : 'Don\'t have an account? Sign Up')),
                      ),
                      if (signState.error != null) ...[
                        SizedBox(height: isLargeScreen ? 24 : 16),
                        Text(
                          signState.error is AppError
                              ? ErrorLocalizer.localizeError(
                                  (signState.error as AppError).message,
                                  language,
                                )
                              : ErrorLocalizer.localizeError(
                                  'An error occurred. Please try again',
                                  language,
                                ),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
