import 'dart:io';

class PlatformUtil {
  PlatformUtil._();

  static String get current {
    if (Platform.isAndroid) {
      return 'android';
    }

    if (Platform.isIOS) {
      return 'ios';
    }

    return 'unknown';
  }

  static bool get isAndroid => Platform.isAndroid;

  static bool get isIOS => Platform.isIOS;
}
