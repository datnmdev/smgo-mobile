import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/splash/presentation/pages/splash_page.dart';

final List<GoRoute> splashRoutes = [
  GoRoute(
    name: AppRouteNames.splash,
    path: '/',
    builder: (context, state) => SplashPage(),
  ),
];
