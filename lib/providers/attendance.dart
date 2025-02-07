import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AttendanceProvider extends ChangeNotifier {
  final double targetLatitude = 37.5665; // 설정된 위치의 위도 (예: 서울)
  final double targetLongitude = 126.9780; // 설정된 위치의 경도 (예: 서울)
  final double allowedDistance = 100.0; // 허용 거리 (미터 단위)

  String _statusMessage = "출석 버튼을 눌러주세요.";
  bool _isChecking = false;
  LatLng? _currentPosition; // 현재 위치 저장

  String get statusMessage => _statusMessage;
  bool get isChecking => _isChecking;
  LatLng? get currentPosition => _currentPosition;

  String? supabaseUrl;
  String? supabaseKey;

  // 실행 인수에서 URL 및 Key 초기화
  void initializeWithArgs(List<String> args) {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    supabaseKey = const String.fromEnvironment('SUPABASE_KEY');

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Supabase URL 또는 Key가 누락되었습니다!');
    }

    print('Supabase URL: $supabaseUrl');
    print('Supabase Key: $supabaseKey');
  }

  Future<void> checkAttendance() async {
    _isChecking = true;
    _statusMessage = "위치를 확인 중입니다...";
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusMessage = "위치 서비스가 비활성화되어 있습니다.";
        _isChecking = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _statusMessage = "위치 권한이 거부되었습니다.";
          _isChecking = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _statusMessage = "위치 권한이 영구적으로 거부되었습니다.";
        _isChecking = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);

      double distanceInMeters = Geolocator.distanceBetween(
        targetLatitude,
        targetLongitude,
        position.latitude,
        position.longitude,
      );

      DateTime currentUtcTime = DateTime.now().toUtc();

      if (distanceInMeters <= allowedDistance) {
        _statusMessage =
            "출석 완료! \n현재 UTC 시간: $currentUtcTime\n거리: ${distanceInMeters.toStringAsFixed(2)}m";
      } else {
        _statusMessage =
            "설정된 위치에서 너무 멀리 있습니다.\n현재 거리: ${distanceInMeters.toStringAsFixed(2)}m";
      }
    } catch (e) {
      _statusMessage = "오류 발생: $e";
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }
}

// 인수에서 값 추출
String? _getArgValue(List<String> args, String key) {
  final arg = args.firstWhere(
    (arg) => arg.startsWith(key),
    orElse: () => '',
  );
  return arg.isNotEmpty ? arg.split('=').last : null;
}
