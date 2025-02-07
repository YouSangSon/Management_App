import 'package:app/providers/attendance.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

mixin AttendanceScreen implements StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('출석 확인'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: provider.currentPosition == null
                ? Center(
                    child: Text(
                      '지도에 현재 위치를 표시하려면 출석 버튼을 눌러주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: provider.currentPosition!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: provider.currentPosition!,
                        infoWindow: InfoWindow(title: '현재 위치'),
                      ),
                    },
                  ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    provider.statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: provider.isChecking
                        ? null
                        : () async {
                            await provider.checkAttendance();
                          },
                    child: provider.isChecking
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('확인 중...'),
                            ],
                          )
                        : Text('출석 확인'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
