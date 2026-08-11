import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoUtil {
  PackageInfoUtil._();

  static Future<String> getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<int> getBuildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
