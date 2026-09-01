import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class DeleteDeliveryRoutesUsecase
    implements Usecase<DataState<dynamic>, DeleteDeliveryRoutesUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const DeleteDeliveryRoutesUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required DeleteDeliveryRoutesUsecaseParams params,
  }) {
    return deliveryRouteRepository.deleteDeliveryRoutes(
      params: DeleteDeliveryRoutesParams(
        deliveryRouteIds: params.deliveryRouteIds,
      ),
    );
  }
}

class DeleteDeliveryRoutesUsecaseParams {
  final List<String> deliveryRouteIds;

  const DeleteDeliveryRoutesUsecaseParams({required this.deliveryRouteIds});
}
