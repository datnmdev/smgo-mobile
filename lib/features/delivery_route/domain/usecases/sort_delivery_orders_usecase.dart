import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class SortDeliveryOrdersUsecase
    implements Usecase<DataState<dynamic>, SortDeliveryOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  SortDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required SortDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.sortDeliveryOrders(
      deliveryRouteId: params.deliveryRouteId,
      source: params.source
    );
  }
}

class SortDeliveryOrdersUsecaseParams {
  final String deliveryRouteId;
  final Point source;

  SortDeliveryOrdersUsecaseParams({required this.deliveryRouteId, required this.source});
}
