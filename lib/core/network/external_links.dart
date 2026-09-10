import 'package:smgo/core/config/env.dart';

abstract class ExternalLinks {
  // Trang chủ website SmGo
  static final homepage = Env.serverBaseUrl;

  // Điều khoản dịch vụ
  static final termsOfService = '${Env.serverBaseUrl}/terms-of-service';

  // Chính sách quyền riêng tư
  static final privacyPolicy = '${Env.serverBaseUrl}/privacy-policy';

  // Liên kết xoá tài khoản
  static final accountDeletion = '${Env.serverBaseUrl}/account-deletion';

  // Liên kết tham gia nhóm facebook
  static final facebookGroup = 'https://www.facebook.com/share/g/1DQgHbxfey/';

  // Liên kết tham gia nhóm zalo
  static final zaloGroup = 'https://zalo.me/g/2367ucr5janxotvrrhpt';

  // Liên kết tham gia nhóm messenger
  static final messengerGroup =
      'https://m.me/cm/RHQR-ncMtB6kPOxI/?send_source=cm%3Acopy_invite_link';

  // Hướng dẫn sử dụng
  static final guide = '${Env.serverBaseUrl}/guide';

  // Google Play
  static final googlePlayStore =
      'https://play.google.com/store/apps/details?id=${Env.packageName}';

  // App Store
  static const appStore = 'https://apps.apple.com/app/idAPP_STORE_ID';
}
