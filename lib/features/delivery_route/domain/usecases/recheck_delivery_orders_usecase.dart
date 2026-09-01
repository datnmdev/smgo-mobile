import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class RecheckDeliveryOrdersUsecase
    implements Usecase<DataState<dynamic>, RecheckDeliveryOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  RecheckDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required RecheckDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.recheckDeliveryOrders(
      deliveryRouteId: params.deliveryRouteId,
      deliveryOrderIds: params.deliveryOrderIds,
    );
  }
}

class RecheckDeliveryOrdersUsecaseParams {
  final String deliveryRouteId;
  final List<String> deliveryOrderIds;

  RecheckDeliveryOrdersUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderIds,
  });
}
