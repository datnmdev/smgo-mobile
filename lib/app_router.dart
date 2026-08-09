import 'package:go_router/go_router.dart';
import 'package:shipgo/features/auth/auth_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    ...authRoutes
  ],
);