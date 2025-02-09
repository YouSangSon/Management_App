import 'package:flutter/foundation.dart';

/// 플랫폼별 구현을 관리하는 유틸리티 클래스

/// 앱이 웹에서 실행 중인지 확인합니다.
bool get isRunningOnWeb => kIsWeb;

/// 앱이 모바일 장치에서 실행 중인지 확인합니다.
bool get isRunningOnMobile {
  if (kIsWeb) return false;

  // 다른 플랫폼 검사 로직 추가
  // (현재는 단순화를 위해 웹이 아니면 모바일로 간주)
  return true;
}

/// 로그 저장 디렉토리 경로를 반환합니다.
String getLogDirectoryName() {
  if (kIsWeb) {
    return 'web_logs';
  } else {
    return 'logs';
  }
}

/// 운영체제 종류를 반환합니다. (간소화된 버전)
enum OperatingSystem { web, android, iOS, windows, macOS, linux, unknown }

/// 현재 실행 중인 운영체제를 반환합니다.
OperatingSystem getCurrentOS() {
  if (kIsWeb) return OperatingSystem.web;

  // 웹이 아닌 경우 현재는 unknown 반환
  // 실제 앱에서는 Platform 클래스를 사용하여 상세 운영체제 확인
  return OperatingSystem.unknown;
}
