import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:erp/core/errors/error_model.dart';
import 'dart:io' if (dart.library.html) 'package:erp/core/utils/web_stub.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'package:erp/core/utils/mock_path_provider.dart';
import 'package:intl/intl.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late final Logger _logger;

  // 파일 로깅을 위한 디렉토리
  String? _logDirectoryPath;
  bool _isFileLoggerInitialized = false;
  bool _isWeb = kIsWeb;
  List<Map<String, dynamic>> _webLogs = [];

  factory AppLogger() => _instance;

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
      level: kDebugMode ? Level.trace : Level.warning,
    );
  }

  // 명시적 초기화 메서드
  Future<void> initialize() async {
    if (!_isFileLoggerInitialized) {
      await _initializeFileLogger();
    }
  }

  // 파일 로깅 초기화 함수
  Future<void> _initializeFileLogger() async {
    try {
      if (_isWeb) {
        _isFileLoggerInitialized = true;
        _logDirectoryPath = 'web_logs';
        logInfo('Web logger initialized (logs stored in memory)');
        return;
      }

      // 네이티브 플랫폼에서만 실행
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logDirectoryPath = logDir.path;
      _isFileLoggerInitialized = true;

      logInfo('File logger initialized: $_logDirectoryPath');
    } catch (e) {
      _logger.e('Failed to initialize file logger', error: e);
      _isFileLoggerInitialized = false;
    }
  }

  // 에러를 파일로 저장하는 함수
  Future<String?> saveErrorToFile(dynamic error,
      {StackTrace? stackTrace, String? context}) async {
    if (!_isFileLoggerInitialized) {
      await initialize();
    }

    try {
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final errorMessage = error.toString();
      final stackTraceString = (stackTrace ?? StackTrace.current).toString();
      final contextInfo = context != null ? 'Context: $context\n' : '';

      final content = '''
======== ERROR LOG: $timestamp ========
$contextInfo
ERROR: $errorMessage

STACK TRACE:
$stackTraceString
========================================
''';

      if (_isWeb) {
        // 웹에서는 메모리에 로그 저장
        _webLogs.add({
          'timestamp': timestamp,
          'context': context,
          'error': errorMessage,
          'stackTrace': stackTraceString,
          'content': content
        });

        // 콘솔에도 출력
        print('=== WEB ERROR LOG ===');
        print(content);
        print('====================');

        return 'web_log_${timestamp}';
      } else {
        // 네이티브 플랫폼에서는 파일에 저장
        final fileName = 'error_${timestamp}.txt';
        final file = File('$_logDirectoryPath/$fileName');

        await file.writeAsString(content);
        logInfo('Error saved to file: ${file.path}');
        return file.path;
      }
    } catch (e) {
      _logger.e('Failed to save error to file', error: e);
      return null;
    }
  }

  void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (error is AppError) {
      _logger.e(
        '[$context] ${error.source} Error: ${error.message}',
        error: error.originalError ?? error,
        stackTrace: error.stackTrace ?? stackTrace ?? StackTrace.current,
      );
    } else {
      _logger.e(
        '[$context] Error',
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }

    // 에러를 파일로도 저장
    saveErrorToFile(error, stackTrace: stackTrace, context: context)
        .then((filePath) {
      if (filePath != null) {
        _logger.i('Error saved to: $filePath');
      }
    });
  }

  void logInfo(String message) {
    _logger.i(message);
  }

  void logDebug(String message) {
    _logger.d(message);
  }

  void logWarning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void logVerbose(String message) {
    _logger.t(message);
  }

  // 웹 환경에서 저장된 로그를 문자열로 반환
  String getWebLogsAsString() {
    if (!_isWeb || _webLogs.isEmpty) return 'No logs available';

    final buffer = StringBuffer();
    for (final log in _webLogs) {
      buffer.writeln(log['content']);
      buffer.writeln('-----------------------------------');
    }

    return buffer.toString();
  }

  // 저장된 로그를 다운로드 (웹에서만 가능)
  void downloadWebLogs() {
    if (!_isWeb || _webLogs.isEmpty) return;

    try {
      if (kIsWeb) {
        // 웹에서만 실행되는 코드
        downloadWebLogsImpl(getWebLogsAsString());
      } else {
        logInfo('다운로드 기능은 웹에서만 지원됩니다.');
      }
    } catch (e) {
      _logger.e('Failed to download logs', error: e);
    }
  }

  // 플랫폼 의존적인 구현은 별도 메서드로 분리
  void downloadWebLogsImpl(String content) {
    // 구현은 web_stub.dart 또는 실제 웹 환경에서 제공됨
    logInfo('웹 로그 다운로드 시도 (stub)');
  }

  // Call this when app is closing to free resources
  void close() {
    _logger.close();
  }
}
