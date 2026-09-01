import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class ConfirmSortedDeliveryOrdersUsecase
    implements
        Usecase<DataState<dynamic>, ConfirmSortedDeliveryOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  ConfirmSortedDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required ConfirmSortedDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.confirmSortedDeliveryOrders(
      deliveryRouteId: params.deliveryRouteId,
      deliveryOrderIds: params.deliveryOrderIds,
    );
  }
}

class ConfirmSortedDeliveryOrdersUsecaseParams {
  final String deliveryRouteId;
  final List<String> deliveryOrderIds;

  ConfirmSortedDeliveryOrdersUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderIds,
  });
}
