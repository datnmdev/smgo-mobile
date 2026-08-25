import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class ConfirmDeliveryOrdersUsecase
    implements Usecase<DataState<dynamic>, ConfirmDeliveryOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  ConfirmDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required ConfirmDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.confirmDeliveryOrders(
      deliveryRouteId: params.deliveryRouteId,
      deliveryOrderIds: params.deliveryOrderIds,
    );
  }
}

class ConfirmDeliveryOrdersUsecaseParams {
  final String deliveryRouteId;
  final List<String> deliveryOrderIds;

  ConfirmDeliveryOrdersUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderIds,
  });
}
