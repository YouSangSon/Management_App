import 'package:flutter/foundation.dart';

void checkPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      if (kDebugMode) {
        print('플랫폼: Android');
      }
      break;
    case TargetPlatform.iOS:
      if (kDebugMode) {
        print('플랫폼: iOS');
      }
      break;
    case TargetPlatform.fuchsia:
      if (kDebugMode) {
        print('플랫폼: Fuchsia');
      }
      break;
    case TargetPlatform.macOS:
      if (kDebugMode) {
        print('플랫폼: macOS');
      }
      break;
    case TargetPlatform.windows:
      if (kDebugMode) {
        print('플랫폼: Windows');
      }
      break;
    case TargetPlatform.linux:
      if (kDebugMode) {
        print('플랫폼: Linux');
      }
      break;
  }
}
