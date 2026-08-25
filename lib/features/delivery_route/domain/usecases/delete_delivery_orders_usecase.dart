import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class DeleteDeliveryOrdersUsecase
    implements Usecase<DataState<dynamic>, DeleteDeliveryOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const DeleteDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required DeleteDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.deleteDeliveryOrders(
      params: DeleteDeliveryOrdersParams(
        deliveryRouteId: params.deliveryRouteId,
        deliveryOrderIds: params.deliveryOrderIds,
      ),
    );
  }
}

class DeleteDeliveryOrdersUsecaseParams {
  final String deliveryRouteId;
  final List<String> deliveryOrderIds;

  const DeleteDeliveryOrdersUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderIds,
  });
}
