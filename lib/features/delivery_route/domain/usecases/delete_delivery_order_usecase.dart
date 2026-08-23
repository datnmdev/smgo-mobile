import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class DeleteDeliveryOrderUsecase
    implements Usecase<DataState<dynamic>, DeleteDeliveryOrderUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const DeleteDeliveryOrderUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required DeleteDeliveryOrderUsecaseParams params,
  }) {
    return deliveryRouteRepository.deleteDeliveryOrder(
      params: DeleteDeliveryOrderParams(
        deliveryRouteId: params.deliveryRouteId,
        deliveryOrderId: params.deliveryOrderId,
      ),
    );
  }
}

class DeleteDeliveryOrderUsecaseParams {
  final String deliveryRouteId;
  final String deliveryOrderId;

  const DeleteDeliveryOrderUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderId,
  });
}
