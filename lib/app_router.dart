import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:shipgo/features/explore/presentation/pages/explore_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_page.dart';
import 'package:shipgo/features/main/presentation/pages/main_page.dart';
import 'package:shipgo/features/person/presentation/pages/person_page.dart';
import 'package:shipgo/features/route/presentation/pages/route_page.dart';
import 'package:shipgo/features/splash/presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: AppRouteNames.splash,
      path: '/',
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      name: AppRouteNames.signIn,
      path: '/login',
      builder: (context, state) => SignInPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRouteNames.explore,
              path: '/explore',
              builder: (context, state) => const ExplorePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRouteNames.location,
              path: '/location',
              builder: (context, state) => const LocationPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRouteNames.route,
              path: '/route',
              builder: (context, state) => const RoutePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRouteNames.person,
              path: '/person',
              builder: (context, state) => const PersonPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
