import 'package:shipgo/features/route/domain/entities/route_entity.dart';

abstract class GetMyRoutesState {
  final bool isFirstLoad;
  final List<RouteEntity> routes;

  const GetMyRoutesState({this.isFirstLoad = true, this.routes = const []});
}

class GetMyRoutesInitial extends GetMyRoutesState {
  const GetMyRoutesInitial();
}

class GetMyRoutesLoading extends GetMyRoutesState {
  const GetMyRoutesLoading({super.isFirstLoad, super.routes});
}

class GetMyRoutesDone extends GetMyRoutesState {
  const GetMyRoutesDone({super.isFirstLoad, super.routes});
}

class GetMyRoutesFailed extends GetMyRoutesState {
  final Object error;

  const GetMyRoutesFailed({
    required this.error,
    super.isFirstLoad,
    super.routes,
  });
}
