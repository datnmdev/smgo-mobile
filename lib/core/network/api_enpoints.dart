abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const authBaseUrl = '/auth';
  static const appVersionBaseUrl = '/app-version';
  static const userBaseUrl = '/user';
  static const locationBaseUrl = '$userBaseUrl/locations';
  static const storageBaseUrl = '/storage';
  static const deliveryRouteBaseUrl = '/delivery-route';
  static const deliveryOrderBaseUrl =
      '/delivery-route/{deliveryRouteId}/delivery-order';
  static const aiBaseUrl = '/ai';

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

  // Delivery route
  static const String getDeliveryRoutes = '$deliveryRouteBaseUrl';
  static const String addDeliveryRoute = '$deliveryRouteBaseUrl';
  static const String updateDeliveryRoute =
      '$deliveryRouteBaseUrl/{deliveryRouteId}';
  static const String deleteDeliveryRoute =
      '$deliveryRouteBaseUrl/{deliveryRouteId}';

  // Delivery order
  static const String getDeliveryOrders = '$deliveryOrderBaseUrl';
  static const String addDeliveryOrder = '$deliveryOrderBaseUrl';
  static const String updateDeliveryOrder =
      '$deliveryOrderBaseUrl/{deliveryOrderId}';
  static const String deleteDeliveryOrder =
      '$deliveryOrderBaseUrl/{deliveryOrderId}';

  // Ai
  static const String extractOrderInfo = '$aiBaseUrl/extract/order-info';
}
