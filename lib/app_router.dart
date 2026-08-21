import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/add_delivery_order_page.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/delivery_route_page.dart';
import 'package:shipgo/features/explore/presentation/pages/explore_page.dart';
import 'package:shipgo/features/location/presentation/pages/add_location_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_detail_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_page.dart';
import 'package:shipgo/features/location/presentation/pages/update_location_page.dart';
import 'package:shipgo/features/main/presentation/pages/main_page.dart';
import 'package:shipgo/features/person/presentation/pages/person_page.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/add_delivery_route_page.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/delivery_order_page.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/delivery_route_detail_page.dart';
import 'package:shipgo/features/delivery_route/presentation/pages/update_delivery_route_page.dart';
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
              name: AppRouteNames.deliveryRoute,
              path: '/delivery-route',
              builder: (context, state) => const DeliveryRoutePage(),
              routes: [
                GoRoute(
                  name: AppRouteNames.addDeliveryRoute,
                  path: '/add',
                  builder: (context, state) => const AddDeliveryRoutePage(),
                ),
                GoRoute(
                  name: AppRouteNames.deliveryRouteDetail,
                  path: '/:id/detail',
                  builder: (context, state) => DeliveryRouteDetailPage(),
                ),
                GoRoute(
                  name: AppRouteNames.updateDeliveryRoute,
                  path: '/:id/update',
                  builder: (context, state) => UpdateDeliveryRoutePage(),
                ),
                GoRoute(
                  name: AppRouteNames.deliveryOrder,
                  path: '/:id/delivery-order',
                  builder: (context, state) => DeliveryOrderPage(),
                ),
                GoRoute(
                  name: AppRouteNames.addDeliveryOrder,
                  path: '/:id/delivery-order/add',
                  builder: (context, state) => AddDeliveryOrderPage(),
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
