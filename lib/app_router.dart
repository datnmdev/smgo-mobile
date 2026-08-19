import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:shipgo/features/explore/presentation/pages/explore_page.dart';
import 'package:shipgo/features/location/presentation/pages/add_location_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_detail_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_page.dart';
import 'package:shipgo/features/location/presentation/pages/update_location_page.dart';
import 'package:shipgo/features/main/presentation/pages/main_page.dart';
import 'package:shipgo/features/person/presentation/pages/person_page.dart';
import 'package:shipgo/features/route/presentation/pages/add_route_page.dart';
import 'package:shipgo/features/route/presentation/pages/route_detail_page.dart';
import 'package:shipgo/features/route/presentation/pages/route_page.dart';
import 'package:shipgo/features/route/presentation/pages/update_route_page.dart';
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
              routes: [
                GoRoute(
                  name: AppRouteNames.addLocation,
                  path: '/add',
                  builder: (context, state) => const AddLocationPage(),
                ),
                GoRoute(
                  name: AppRouteNames.locationDetail,
                  path: '/:id/detail-info',
                  builder: (context, state) => const LocationDetailPage(),
                ),
                GoRoute(
                  name: AppRouteNames.updateLocation,
                  path: '/:id/update',
                  builder: (context, state) => const UpdateLocationPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRouteNames.route,
              path: '/route',
              builder: (context, state) => const RoutePage(),
              routes: [
                GoRoute(
                  name: AppRouteNames.addRoute,
                  path: '/add',
                  builder: (context, state) => const AddRoutePage(),
                ),
                GoRoute(
                  name: AppRouteNames.routeDetail,
                  path: '/:id/detail',
                  builder: (context, state) => RouteDetailPage(),
                ),
                GoRoute(
                  name: AppRouteNames.updateMyRoute,
                  path: '/:id/update',
                  builder: (context, state) => UpdateRoutePage(),
                ),
              ],
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
