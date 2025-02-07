import 'package:flutter/foundation.dart';

void checkPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      print('플랫폼: Android');
      break;
    case TargetPlatform.iOS:
      print('플랫폼: iOS');
      break;
    case TargetPlatform.fuchsia:
      print('플랫폼: Fuchsia');
      break;
    case TargetPlatform.macOS:
      print('플랫폼: macOS');
      break;
    case TargetPlatform.windows:
      print('플랫폼: Windows');
      break;
    case TargetPlatform.linux:
      print('플랫폼: Linux');
      break;
  }
}
