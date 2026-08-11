import 'package:go_router/go_router.dart';
import 'package:shipgo/features/auth/auth_routes.dart';
import 'package:shipgo/features/route/route_routes.dart';
import 'package:shipgo/features/saved_locations_management/saved_locations_management_routes.dart';
import 'package:shipgo/features/splash/splash_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ...authRoutes,
    ...routeRoutes,
    ...splashRoutes,
    ...savedLocationsManagementRoutes
  ],
);