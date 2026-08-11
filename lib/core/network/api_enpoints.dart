abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const authBaseUrl = '/auth';
  static const appVersionBaseUrl = '/app-version';

  // Authentication
  static const String signInWithGoogle = '$authBaseUrl/google';
  static const String signInWithFacebook = '$authBaseUrl/facebook';
  static const String refreshToken = '$authBaseUrl/refresh';

  // App version
  static const String getLatestAppVersion = '$appVersionBaseUrl/latest';
}
