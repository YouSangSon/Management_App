// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// 웹 환경에서만 사용할 유틸리티 함수들입니다.
/// 이 파일은 웹 빌드에서만 포함됩니다.

/// 콘텐츠를 브라우저에서 다운로드합니다.
void downloadString(String content, String fileName) {
  if (!kIsWeb) return;

  final blob = html.Blob([content], 'text/plain');
  final url = html.Url.createObjectUrl(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// 에러 로그를 다운로드합니다.
void downloadErrorLogs(String content) {
  if (!kIsWeb) return;

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  downloadString(content, 'error_logs_$timestamp.txt');
}

/// 현재 창에 경고를 표시합니다.
void showAlert(String message) {
  if (!kIsWeb) return;

  html.window.alert(message);
}

/// 로컬 스토리지에 데이터를 저장합니다.
void saveToLocalStorage(String key, String value) {
  if (!kIsWeb) return;

  html.window.localStorage[key] = value;
}

/// 로컬 스토리지에서 데이터를 불러옵니다.
String? getFromLocalStorage(String key) {
  if (!kIsWeb) return null;

  return html.window.localStorage[key];
}
