import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp/presentation/providers/language_provider.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    // Get screen size
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '개인정보 처리방침' : 'Privacy Policy'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 800 : size.width,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isLargeScreen ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKorean ? '개인정보 처리방침' : 'Privacy Policy',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isKorean
                      ? '최종 수정일: 2025년 2월 25일'
                      : 'Last updated: 2025-02-25',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  isKorean ? '정보 수집 및 사용' : 'Information Collection and Use',
                  isKorean
                      ? [
                          '계정 생성 시 이메일 주소와 같이 귀하가 직접 제공하는 정보를 수집합니다.',
                          '수집된 정보는 서비스 제공, 유지 및 개선을 위해 사용됩니다.',
                        ]
                      : [
                          'We collect information that you provide directly to us, such as your email address when you create an account.',
                          'We use this information to provide, maintain, and improve our services.',
                        ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isKorean ? '데이터 보안' : 'Data Security',
                  isKorean
                      ? [
                          '귀하의 개인정보를 보호하기 위해 적절한 보안 조치를 구현합니다.',
                          '비밀번호는 암호화되어 안전하게 저장됩니다.',
                        ]
                      : [
                          'We implement appropriate security measures to protect your personal information.',
                          'Your password is encrypted and stored securely.',
                        ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isKorean ? '정책 변경' : 'Changes to This Policy',
                  isKorean
                      ? [
                          '본 개인정보 처리방침은 수시로 업데이트될 수 있습니다.',
                          '변경사항이 있을 경우 본 페이지에 게시하여 알려드립니다.',
                        ]
                      : [
                          'We may update this privacy policy from time to time.',
                          'We will notify you of any changes by posting the new policy on this page.',
                        ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isKorean ? '문의하기' : 'Contact Us',
                  isKorean
                      ? [
                          '본 개인정보 처리방침에 대해 문의사항이 있으시면 연락 주시기 바랍니다.',
                        ]
                      : [
                          'If you have any questions about this Privacy Policy, please contact us.',
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...bullets.map((bullet) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
