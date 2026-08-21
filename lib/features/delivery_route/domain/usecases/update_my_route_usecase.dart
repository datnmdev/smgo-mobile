import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class UpdateDeliveryRouteUsecase
    implements Usecase<dynamic, UpdateDeliveryRouteUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const UpdateDeliveryRouteUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateDeliveryRouteUsecaseParams params,
  }) {
    return deliveryRouteRepository.updateDeliveryRoute(
      id: params.id,
      params: UpdateDeliveryRouteParams(name: params.name),
    );
  }
}

class UpdateDeliveryRouteUsecaseParams {
  final String id;
  final String? name;

  const UpdateDeliveryRouteUsecaseParams({required this.id, this.name});
}
