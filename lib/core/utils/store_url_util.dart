import 'dart:io';

class StoreUrlUtil {
  static Uri? getNativeUri(String storeAppId) {
    if (Platform.isAndroid) {
      return Uri.parse('market://details?id=$storeAppId');
    } else if (Platform.isIOS) {
      return Uri.parse('itms-apps://itunes.apple.com/app/id$storeAppId');
    }
    return null;
  }

  static Uri? getWebUri(String storeAppId) {
    if (Platform.isAndroid) {
      return Uri.parse(
        'https://play.google.com/store/apps/details?id=$storeAppId',
      );
    } else if (Platform.isIOS) {
      return Uri.parse('https://apps.apple.com/app/id$storeAppId');
    }
    return null;
  }
}
