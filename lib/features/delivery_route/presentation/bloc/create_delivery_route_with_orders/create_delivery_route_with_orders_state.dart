import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';

class CreateDeliveryRouteWithOrdersState {
  const CreateDeliveryRouteWithOrdersState();
}

class CreateDeliveryRouteWithOrdersInitial
    extends CreateDeliveryRouteWithOrdersState {
  const CreateDeliveryRouteWithOrdersInitial();
}

class CreateDeliveryRouteWithOrdersLoading
    extends CreateDeliveryRouteWithOrdersState {
  CreateDeliveryRouteWithOrdersLoading();
}

class CreateDeliveryRouteWithOrdersDone
    extends CreateDeliveryRouteWithOrdersState {
  final DeliveryRouteEntity newDeliveryRoute;
  CreateDeliveryRouteWithOrdersDone({required this.newDeliveryRoute});
}

class CreateDeliveryRouteWithOrdersFailed
    extends CreateDeliveryRouteWithOrdersState {
  final Object error;

  CreateDeliveryRouteWithOrdersFailed({required this.error});
}
