import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';

abstract class GetDeliveryRoutesState {
  final bool isFirstLoad;
  final List<DeliveryRouteEntity> routes;

  const GetDeliveryRoutesState({
    this.isFirstLoad = true,
    this.routes = const [],
  });
}

class GetDeliveryRoutesInitial extends GetDeliveryRoutesState {
  const GetDeliveryRoutesInitial();
}

class GetDeliveryRoutesLoading extends GetDeliveryRoutesState {
  const GetDeliveryRoutesLoading({super.isFirstLoad, super.routes});
}

class GetDeliveryRoutesDone extends GetDeliveryRoutesState {
  const GetDeliveryRoutesDone({super.isFirstLoad, super.routes});
}

class GetDeliveryRoutesFailed extends GetDeliveryRoutesState {
  final Object error;

  const GetDeliveryRoutesFailed({
    required this.error,
    super.isFirstLoad,
    super.routes,
  });
}
