import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class UpdateDeliveryRouteUsecase
    implements Usecase<dynamic, UpdateDeliveryRouteUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const UpdateDeliveryRouteUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateDeliveryRouteUsecaseParams params,
  }) {
    return deliveryRouteRepository.updateDeliveryRoute(
      id: params.deliveryRouteId,
      params: UpdateDeliveryRouteParams(
        name: params.name,
        status: params.status,
      ),
    );
  }
}

class UpdateDeliveryRouteUsecaseParams {
  final String deliveryRouteId;
  final String? name;
  final String? status;

  UpdateDeliveryRouteUsecaseParams({
    required this.deliveryRouteId,
    this.name,
    this.status,
  });
}
