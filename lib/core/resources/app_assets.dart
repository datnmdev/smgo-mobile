abstract class AppAssets {
  AppAssets._();

  // --- Base Paths ---
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _audiosPath = 'assets/audios';

  // --- Images ---
  static const String logo = '$_imagesPath/logo.png';
  static const String bgSplash = '$_imagesPath/bg_splash.jpeg';
  static const String locationEmpty =
      '$_imagesPath/map_location_empty_state.png';

  // --- Icons ---
  static const String icGoogle = '$_iconsPath/google.png';
  static const String icFacebook = '$_iconsPath/facebook.png';
  static const String icZalo = '$_iconsPath/zalo.png';
  static const String icGoogleMaps = '$_iconsPath/google-maps.png';

  // --- Translations ---
  static const String translations = 'assets/translations';

  // --- Audios ---
  static const String audioBeep = '$_audiosPath/beep.mp3';
}
