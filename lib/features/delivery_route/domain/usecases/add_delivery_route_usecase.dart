import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class AddDeliveryRouteUsecase
    implements Usecase<dynamic, AddDeliveryRouteUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const AddDeliveryRouteUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required AddDeliveryRouteUsecaseParams params,
  }) {
    return deliveryRouteRepository.addDeliveryRoute(
      params: AddDeliveryRouteParams(name: params.name),
    );
  }
}

class AddDeliveryRouteUsecaseParams {
  final String name;

  const AddDeliveryRouteUsecaseParams({required this.name});
}
