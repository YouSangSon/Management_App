import 'package:erp/presentation/pages/sign_page.dart';
import 'package:erp/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:erp/presentation/providers/language_provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'dart:ui' as ui;
import 'package:erp/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'package:erp/core/utils/mock_path_provider.dart';

void main() {
  // Set up zone to capture errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set up logging and error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger().logError(
        details.exception,
        stackTrace: details.stack,
        context: 'Flutter Error',
      );
    };

    // Initialize FlutterLocalization
    await FlutterLocalization.instance.ensureInitialized();
    FlutterLocalization.instance.init(
      mapLocales: [
        const MapLocale('en', {}),
        const MapLocale('ko', {}),
      ],
      initLanguageCode: 'en',
    );

    // Initialize AppLogger first
    await AppLogger().initialize();

    // Load environment variables
    await dotenv.load(fileName: 'assets/config/.env');

    // Initialize Supabase
    await _initializeSupabase();

    // Set language
    final deviceLanguageCode =
        ui.PlatformDispatcher.instance.locale.languageCode;
    final initialLanguage =
        deviceLanguageCode == 'ko' ? Language.korean : Language.english;

    // Launch the app
    runApp(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith(
            (ref) => LanguageNotifier(initialLanguage),
          ),
        ],
        child: const MainApp(),
      ),
    );
  }, (error, stack) {
    // Handle unhandled async errors
    AppLogger()
        .logError(error, stackTrace: stack, context: 'Unhandled Zone Error');
    if (kDebugMode) {
      print('Unhandled error in application: $error');
    }
  });
}

// Function to initialize Supabase
Future<void> _initializeSupabase() async {
  String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL or Anon Key is not configured.');
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // Disable deep linking on web
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: true,
      ),
      debug: kDebugMode,
    );

    AppLogger().logInfo('Supabase initialization completed');
  } catch (e, stack) {
    AppLogger().logError(e,
        stackTrace: stack, context: 'Supabase initialization error');
    // Continue app execution even if initialization fails
    AppLogger()
        .logWarning('Supabase initialization failed but app will continue');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isKorean = language == Language.korean;

    return MaterialApp(
      title: isKorean ? '관리 시스템' : 'Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          elevation: 2,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: _getInitialRoute(),
      routes: {
        '/': (context) => const SignPage(),
        '/sign': (context) => const SignPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
      localizationsDelegates:
          FlutterLocalization.instance.localizationsDelegates,
      supportedLocales: FlutterLocalization.instance.supportedLocales,
      // Global UI error handler
      builder: (context, child) {
        // Customize Flutter error widget
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // Show detailed error info in debug mode
          if (kDebugMode) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                color: Colors.red.withAlpha(26),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️ UI Rendering Error',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '${details.exception}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Simple error message in production mode
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isKorean ? '화면 로딩 중 오류가 발생했습니다.' : 'Error loading this view.',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }

  // 이미 로그인 상태라면 대시보드로, 아니면 로그인 페이지로 이동
  String _getInitialRoute() {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null ? '/dashboard' : '/sign';
  }
}
