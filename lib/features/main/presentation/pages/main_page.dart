import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/explore/presentation/pages/explore_page.dart';
import 'package:shipgo/features/location/presentation/pages/location_page.dart';
import 'package:shipgo/features/main/presentation/widgets/app_navigation_bar.dart';
import 'package:shipgo/features/person/presentation/pages/person_page.dart';
import 'package:shipgo/features/route/presentation/pages/route_page.dart';

class MainPage extends StatelessWidget {
  final Map<String, int> tabMap = {
    AppRouteNames.explore: 0,
    AppRouteNames.location: 1,
    AppRouteNames.route: 2,
    AppRouteNames.person: 3,
  };

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabName =
        GoRouterState.of(context).pathParameters['tabName'] ??
        AppRouteNames.explore;
    return Scaffold(
      body: IndexedStack(
        index: tabMap[tabName],
        children: const [
          ExplorePage(),
          LocationPage(),
          RoutePage(),
          PersonPage(),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: tabMap[tabName] ?? 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed(
                AppRouteNames.main,
                pathParameters: {'tabName': AppRouteNames.explore},
              );
              break;
            case 1:
              context.goNamed(
                AppRouteNames.main,
                pathParameters: {'tabName': AppRouteNames.location},
              );
              break;
            case 2:
              context.goNamed(
                AppRouteNames.main,
                pathParameters: {'tabName': AppRouteNames.route},
              );
              break;
            case 3:
              context.goNamed(
                AppRouteNames.main,
                pathParameters: {'tabName': AppRouteNames.person},
              );
              break;
          }
        },
      ),
    );
  }
}
