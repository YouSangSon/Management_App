import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { korean, english }

// Initialize provider with persistent storage
final languageProvider =
    StateNotifierProvider<LanguageNotifier, Language>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Language> {
  LanguageNotifier([Language? initialLanguage])
      : super(initialLanguage ?? Language.english) {
    if (initialLanguage == null) {
      _loadSavedLanguage();
    }
  }

  // Load saved language preference
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    if (savedLanguage != null) {
      state = savedLanguage == 'korean' ? Language.korean : Language.english;
    }
  }

  // Update language and save preference
  Future<void> setLanguage(Language language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'language', language == Language.korean ? 'korean' : 'english');

    // Update app localization
    switch (language) {
      case Language.korean:
        FlutterLocalization.instance.translate('ko');
        break;
      case Language.english:
        FlutterLocalization.instance.translate('en');
        break;
    }
  }
}

// This function can be removed as we now handle it in the notifier
// void changeAppLanguage(Language language, FlutterLocalization localization) {
//   ...
// }
