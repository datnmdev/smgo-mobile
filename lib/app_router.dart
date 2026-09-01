import 'package:go_router/go_router.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/add_delivery_order_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/delivery_order_detail_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/delivery_route_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/search_delivery_order_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/update_delivery_order_page.dart';
import 'package:smgo/features/explore/presentation/pages/explore_page.dart';
import 'package:smgo/features/location/presentation/pages/add_location_page.dart';
import 'package:smgo/features/location/presentation/pages/location_detail_page.dart';
import 'package:smgo/features/location/presentation/pages/location_page.dart';
import 'package:smgo/features/location/presentation/pages/update_location_page.dart';
import 'package:smgo/features/main/presentation/pages/main_page.dart';
import 'package:smgo/features/person/presentation/pages/person_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/add_delivery_route_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/delivery_order_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/delivery_route_detail_page.dart';
import 'package:smgo/features/delivery_route/presentation/pages/update_delivery_route_page.dart';
import 'package:smgo/features/splash/presentation/pages/splash_page.dart';

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
                  builder: (context, state) => LocationDetailPage(),
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
                  routes: [
                    GoRoute(
                      name: AppRouteNames.searchDeliveryOrder,
                      path: '/search',
                      builder: (context, state) => SearchDeliveryOrderPage(),
                    ),
                    GoRoute(
                      name: AppRouteNames.addDeliveryOrder,
                      path: '/add',
                      builder: (context, state) => AddDeliveryOrderPage(),
                    ),
                    GoRoute(
                      name: AppRouteNames.deliveryOrderDetail,
                      path: '/:deliveryOrderId/detail',
                      builder: (context, state) => DeliveryOrderDetailPage(),
                    ),
                    GoRoute(
                      name: AppRouteNames.updateDeliveryOrder,
                      path: '/:deliveryOrderId/update',
                      builder: (context, state) => UpdateDeliveryOrderPage(),
                    ),
                  ],
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
