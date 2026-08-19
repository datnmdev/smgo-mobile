abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const authBaseUrl = '/auth';
  static const appVersionBaseUrl = '/app-version';
  static const userBaseUrl = '/user';
  static const locationBaseUrl = '$userBaseUrl/locations';
  static const storageBaseUrl = '/storage';
  static const routeBaseUrl = '/route';

  // Authentication
  static const String signInWithGoogle = '$authBaseUrl/oauth/google';
  static const String signInWithFacebook = '$authBaseUrl/oauth/facebook';
  static const String refreshToken = '$authBaseUrl/refresh';

  // App version
  static const String getLatestAppVersion = '$appVersionBaseUrl/latest';

  // Location
  static const String updateLocation = '$locationBaseUrl/{locationId}';
  static const String deleteLocation = '$locationBaseUrl/{locationId}';

  // Storage
  static const String getUploadUrl = '$storageBaseUrl/file/upload';
  static const String getDownloadUrl = '$storageBaseUrl/file/download';

  // Route
  static const String getMyRoutes = '$routeBaseUrl/mine';
  static const String addRoute = '$routeBaseUrl/mine';
  static const String updateMyRoute = '$routeBaseUrl/mine/{routeId}';
  static const String deleteMyRoute = '$routeBaseUrl/mine/{routeId}';
}
