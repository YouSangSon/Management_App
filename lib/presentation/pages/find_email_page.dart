import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FindEmailPage extends ConsumerStatefulWidget {
  const FindEmailPage({super.key});

  @override
  ConsumerState<FindEmailPage> createState() => _FindEmailPageState();
}

class _FindEmailPageState extends ConsumerState<FindEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  String? _foundEmail;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _findEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();

    if (fullName.isEmpty && username.isEmpty) {
      setState(() {
        _message = ref.read(languageProvider) == Language.korean
            ? '이름 또는 사용자 이름을 입력해주세요.'
            : 'Please enter at least your full name or username.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _foundEmail = null;
    });

    try {
      // Build the query based on provided information
      final query = Supabase.instance.client.from('userInfo').select('email');

      if (fullName.isNotEmpty) {
        query.ilike('full_name', '%$fullName%');
      }

      if (username.isNotEmpty) {
        query.ilike('username', '%$username%');
      }

      final data = await query.limit(1);

      if (data.isNotEmpty && data[0]['email'] != null) {
        // Mask part of the email for privacy
        final email = data[0]['email'] as String;
        final maskedEmail = _maskEmail(email);

        setState(() {
          _foundEmail = maskedEmail;
          _message = ref.read(languageProvider) == Language.korean
              ? '계정을 찾았습니다. 아래 이메일로 로그인하세요.'
              : 'We found your account. Please sign in with the email below.';
        });
      } else {
        setState(() {
          _message = ref.read(languageProvider) == Language.korean
              ? '일치하는 계정을 찾을 수 없습니다.'
              : 'No matching account found.';
        });
      }
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mask the email to show only first character and domain
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    String maskedName =
        name.length > 1 ? name[0] + '*' * (name.length - 1) : name;

    return '$maskedName@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '이메일 찾기' : 'Find Email'),
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
                        isKorean ? '이메일 찾기' : 'Find Your Email',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isKorean
                            ? '가입 시 입력한 이름 또는 사용자 이름을 입력하세요.'
                            : 'Enter the full name or username you used when registering.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: isKorean ? '이름' : 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: isKorean ? '사용자 이름' : 'Username',
                          prefixIcon: const Icon(Icons.account_circle),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _findEmail,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(isKorean ? '이메일 찾기' : 'Find Email'),
                            ),
                      if (_foundEmail != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isKorean ? '귀하의 이메일:' : 'Your email:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _foundEmail!,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_message != null && _foundEmail == null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message!,
                          style: const TextStyle(color: Colors.red),
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
