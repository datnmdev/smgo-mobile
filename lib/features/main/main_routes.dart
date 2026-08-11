import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/features/main/presentation/pages/main_page.dart';

List<GoRoute> mainRoutes = [
  GoRoute(
    name: AppRouteNames.main,
    path: '/:tabName',
    builder: (context, state) => MainPage(),
  ),
];
