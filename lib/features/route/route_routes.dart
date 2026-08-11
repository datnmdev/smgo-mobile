import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/route/presentation/pages/route_management_page.dart';

final List<GoRoute> routeRoutes = [
  GoRoute(
    name: AppRouteNames.routeManagement,
    path: '/route-management',
    builder: (context, state) => RouteManagementPage(),
  ),
];
