abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const authBaseUrl = '/auth';
  static const appVersionBaseUrl = '/app-version';
  static const userBaseUrl = '/user';
  static const myLocationBaseUrl = '$userBaseUrl/locations';
  static const storageBaseUrl = '/storage';
  static const deliveryRouteBaseUrl = '/delivery-route';
  static const deliveryOrderBaseUrl =
      '/delivery-route/{deliveryRouteId}/delivery-order';
  static const aiBaseUrl = '/ai';
  static const locationBaseUrl = '/location';

  // Authentication
  static const String signInWithGoogle = '$authBaseUrl/oauth/google';
  static const String signInWithFacebook = '$authBaseUrl/oauth/facebook';
  static const String refreshToken = '$authBaseUrl/refresh';

  // User
  static const String getProfile = '$userBaseUrl/profile';

  // App version
  static const String getLatestAppVersion = '$appVersionBaseUrl/latest';

  // Location
  static const String getMyLocations = '$myLocationBaseUrl';
  static const String createLocation = '$myLocationBaseUrl';
  static const String updateLocation = '$myLocationBaseUrl/{locationId}';
  static const String deleteLocations = '$myLocationBaseUrl/m';
  static const String getLocationSuggestions = '$locationBaseUrl/suggestions';

  // Storage
  static const String getUploadUrl = '$storageBaseUrl/file/upload';
  static const String getDownloadUrl = '$storageBaseUrl/file/download';

  // Delivery route
  static const String getDeliveryRoutes = '$deliveryRouteBaseUrl';
  static const String addDeliveryRoute = '$deliveryRouteBaseUrl';
  static const String createDeliveryRouteWithOrders =
      '$deliveryRouteBaseUrl/with-orders';
  static const String updateDeliveryRoute =
      '$deliveryRouteBaseUrl/{deliveryRouteId}';
  static const String deleteDeliveryRoutes = '$deliveryRouteBaseUrl/m';

  // Delivery order
  static const String getDeliveryOrders = '$deliveryOrderBaseUrl';
  static const String addDeliveryOrder = '$deliveryOrderBaseUrl';
  static const String updateDeliveryOrder =
      '$deliveryOrderBaseUrl/{deliveryOrderId}';
  static const String deleteDeliveryOrders = '$deliveryOrderBaseUrl/m';
  static const String recheckDeliveryOrders = '$deliveryOrderBaseUrl/m/recheck';
  static const String confirmDeliveryOrders = '$deliveryOrderBaseUrl/m/confirm';
  static const String sortDeliveryOrders = '$deliveryOrderBaseUrl/m/sort';
  static const String confirmSortedDeliveryOrders =
      '$deliveryOrderBaseUrl/m/confirm-sorted';

  // Ai
  static const String extractOrderInfo = '$aiBaseUrl/extract/order-info';
}
