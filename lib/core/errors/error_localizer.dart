import 'package:erp/presentation/providers/language_provider.dart';

class ErrorLocalizer {
  static String localizeError(String message, Language language) {
    final isKorean = language == Language.korean;

    final Map<String, String> localizationMap = {
      // Auth errors
      'Invalid email or password': '이메일 또는 비밀번호가 올바르지 않습니다',
      'Email is already in use': '이미 사용 중인 이메일입니다',
      'Password is too weak': '비밀번호가 너무 약합니다',
      'User not found': '사용자를 찾을 수 없습니다',
      'Email not verified': '이메일이 인증되지 않았습니다',

      // Network errors
      'Connection failed. Please check your internet connection':
          '연결에 실패했습니다. 인터넷 연결을 확인해주세요',
      'Request timed out. Please try again': '요청 시간이 초과되었습니다. 다시 시도해주세요',

      // Common errors
      'An error occurred. Please try again': '오류가 발생했습니다. 다시 시도해주세요',
      'Operation failed': '작업에 실패했습니다',
    };

    if (isKorean) {
      return localizationMap[message] ?? message;
    }

    return message;
  }
}
