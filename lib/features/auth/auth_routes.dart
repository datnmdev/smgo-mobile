import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/auth/presentation/pages/sign_in_page.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    name: AppRouteNames.signIn,
    path: '/login',
    builder: (context, state) => SignInPage(),
  ),
];
