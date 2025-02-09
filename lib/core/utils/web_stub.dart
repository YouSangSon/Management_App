// 웹 환경과 비웹 환경에서 공통으로 사용할 클래스와 함수
// 네이티브 환경에서는 이 스텁 구현이 사용됩니다.

// dart:io에서 가져온 File 클래스와 호환되게 설계
class File {
  final String path;

  File(this.path);

  Future<bool> exists() async => false;

  Future<File> create({bool recursive = false}) async => this;

  Future<void> writeAsString(String contents) async {}

  Future<String> readAsString() async => '';
}
