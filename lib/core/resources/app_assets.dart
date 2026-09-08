abstract class AppAssets {
  AppAssets._();

  // --- Base Paths ---
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _audiosPath = 'assets/audios';

  // --- Images ---
  static const String logo = '$_imagesPath/logo.png';
  static const String logoText = '$_imagesPath/logo_text.png';
  static const String bgSplash = '$_imagesPath/bg_splash.png';
  static const String locationEmpty =
      '$_imagesPath/map_location_empty_state.png';
  static const String defaultAvatar = '$_imagesPath/default_avatar.png';
  static String getSmartSortingCarousel({required String lang}) =>
      '$_imagesPath/smart_sorting_$lang.png';
  static String getOptimizedRouteCarousel({required String lang}) =>
      '$_imagesPath/optimized_route_$lang.png';
  static String getSaveLocationSmartCarousel({required String lang}) =>
      '$_imagesPath/save_location_smart_$lang.png';
  static String getRequireShareLocationCarousel({required String lang}) =>
      '$_imagesPath/require_share_location_$lang.png';
  static String getImportOrderInfoFastCarousel({required String lang}) =>
      '$_imagesPath/import_order_info_fast_$lang.png';

  // --- Icons ---
  static const String icGoogle = '$_iconsPath/google.png';
  static const String icFacebook = '$_iconsPath/facebook.png';
  static const String icZalo = '$_iconsPath/zalo.png';
  static const String icGoogleMaps = '$_iconsPath/google-maps.png';
  static const String icMessenger = '$_iconsPath/messenger.png';

  // --- Translations ---
  static const String translations = 'assets/translations';

  // --- Audios ---
  static const String audioBeep = '$_audiosPath/beep.mp3';
}
