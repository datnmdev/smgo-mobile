import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class DeleteDeliveryRouteUsecase
    implements Usecase<DataState<dynamic>, DeleteDeliveryRouteUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const DeleteDeliveryRouteUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required DeleteDeliveryRouteUsecaseParams params,
  }) {
    return deliveryRouteRepository.deleteDeliveryRoute(
      params: DeleteDeliveryRouteParams(id: params.id),
    );
  }
}

class DeleteDeliveryRouteUsecaseParams {
  final String id;

  const DeleteDeliveryRouteUsecaseParams({required this.id});
}
