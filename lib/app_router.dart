import 'package:go_router/go_router.dart';
import 'package:shipgo/features/auth/auth_routes.dart';
import 'package:shipgo/features/main/main_routes.dart';
import 'package:shipgo/features/splash/splash_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ...authRoutes,
    ...splashRoutes,
    ...mainRoutes
  ],
);