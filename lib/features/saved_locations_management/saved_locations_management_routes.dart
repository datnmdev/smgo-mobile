import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/saved_locations_management/presentation/pages/saved_locations_management_page.dart';

List<GoRoute> savedLocationsManagementRoutes = [
  GoRoute(
    name: AppRouteNames.myLocationList,
    path: '/saved-locations',
    builder: (context, state) => SavedLocationsManagementPage(),
  ),
];
