import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class AddDeliveryOrderUsecase
    implements Usecase<dynamic, AddDeliveryOrderUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const AddDeliveryOrderUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required AddDeliveryOrderUsecaseParams params,
  }) {
    return deliveryRouteRepository.addDeliveryOrder(
      params: AddDeliveryOrderParams(
        deliveryRouteId: params.deliveryRouteId,
        orderCode: params.orderCode,
        orderName: params.orderName,
        orderMediaId: params.orderMediaId,
        contactName: params.contactName,
        contactPhone: params.contactPhone,
        address: params.address,
        appliedLocationId: params.appliedLocationId,
        location: PointParam(x: params.location.x, y: params.location.y),
      ),
    );
  }
}

class PointUsecaseParam {
  final double x;
  final double y;

  PointUsecaseParam({required this.x, required this.y});
}

class AddDeliveryOrderUsecaseParams {
  final String deliveryRouteId;
  final String orderCode;
  final String? orderName;
  final String? orderMediaId;
  final String contactName;
  final String contactPhone;
  final String address;
  final String? appliedLocationId;
  final PointUsecaseParam location;

  AddDeliveryOrderUsecaseParams({
    required this.deliveryRouteId,
    required this.orderCode,
    required this.orderName,
    this.orderMediaId,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    this.appliedLocationId,
    required this.location,
  });
}
