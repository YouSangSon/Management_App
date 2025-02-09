import 'dart:io';

// 웹 환경에서 path_provider를 모킹하기 위한 파일
// 실제 path_provider를 대체하는 목적으로 사용됩니다

class Directory {
  final String path;

  Directory(this.path);

  Future<bool> exists() async => true;

  Future<Directory> create({bool recursive = false}) async => this;
}

Future<Directory> getApplicationDocumentsDirectory() async {
  // 웹 환경에서는 가상 경로를 반환합니다
  return Directory('/web_documents');
}

Future<Directory> getTemporaryDirectory() async {
  // 웹 환경에서는 가상 경로를 반환합니다
  return Directory('/web_temp');
}

Future<Directory> getLibraryDirectory() async {
  // 웹 환경에서는 가상 경로를 반환합니다
  return Directory('/web_library');
}

Future<Directory> getExternalStorageDirectory() async {
  // 웹 환경에서는 가상 경로를 반환합니다
  return Directory('/web_external_storage');
}
