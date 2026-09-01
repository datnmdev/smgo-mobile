import 'package:smgo/core/utils/store_url_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateUtil {
  static Future<void> openAppStore({required String storeAppId}) async {
    final Uri? storeUri = StoreUrlUtil.getNativeUri(storeAppId);
    final Uri? fallbackWebUri = StoreUrlUtil.getWebUri(storeAppId);
    if (storeUri == null || fallbackWebUri == null) {
      return;
    }
    try {
      bool launched = await launchUrl(
        storeUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}
