import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:erp/presentation/providers/sign_provider.dart';

class EmailConfirmationPage extends ConsumerStatefulWidget {
  final String email;

  const EmailConfirmationPage({super.key, required this.email});

  @override
  ConsumerState<EmailConfirmationPage> createState() =>
      _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends ConsumerState<EmailConfirmationPage> {
  bool _isResending = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _resendConfirmationEmail() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      await ref
          .read(signProvider.notifier)
          .resendConfirmationEmail(widget.email);

      setState(() {
        _isSuccess = true;
        _message = ref.read(languageProvider) == Language.korean
            ? '확인 이메일이 다시 전송되었습니다.'
            : 'Confirmation email has been resent.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isResending = false;
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
        title: Text(isKorean ? '이메일 확인' : 'Email Confirmation'),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_email_unread,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isKorean ? '이메일 확인이 필요합니다' : 'Verify Your Email',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isKorean
                          ? '${widget.email}로 확인 이메일을 보냈습니다.\n이메일의 링크를 클릭하여 가입을 완료해 주세요.'
                          : 'We\'ve sent a confirmation email to ${widget.email}.\nPlease click the link in the email to complete your registration.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _isResending
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _resendConfirmationEmail,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(isKorean
                                ? '확인 이메일 다시 보내기'
                                : 'Resend Confirmation Email'),
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
                      child:
                          Text(isKorean ? '로그인 화면으로 돌아가기' : 'Back to Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
