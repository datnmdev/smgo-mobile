import 'package:url_launcher/url_launcher.dart';

class AppUrlUtils {
  static Future<bool> launchLink(String link) async {
    final Uri url = Uri.parse(link);
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
