import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';
import 'package:smgo/shared/domain/entities/point_entity.dart';

class UpdateDeliveryOrderUsecase
    implements Usecase<dynamic, UpdateDeliveryOrderUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const UpdateDeliveryOrderUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateDeliveryOrderUsecaseParams params,
  }) {
    return deliveryRouteRepository.updateDeliveryOrder(
      params: UpdateDeliveryOrderParams(
        deliveryRouteId: params.deliveryRouteId,
        deliveryOrderId: params.deliveryOrderId,
        orderCode: params.orderCode,
        orderName: params.orderName,
        status: params.status,
        orderMediaId: params.orderMediaId,
        contactName: params.contactName,
        contactPhone: params.contactPhone,
        address: params.address,
        appliedLocationId: params.appliedLocationId,
        location: params.location != null
            ? PointParam(x: params.location!.x, y: params.location!.y)
            : null,
      ),
    );
  }
}

class UpdateDeliveryOrderUsecaseParams {
  final String deliveryRouteId;
  final String deliveryOrderId;
  final String? orderCode;
  final String? orderName;
  final String? status;
  final String? orderMediaId;
  final String? contactName;
  final String? contactPhone;
  final String? address;
  final String? appliedLocationId;
  final PointEntity? location;

  UpdateDeliveryOrderUsecaseParams({
    required this.deliveryRouteId,
    required this.deliveryOrderId,
    this.orderCode,
    this.orderName,
    this.orderMediaId,
    this.status,
    this.contactName,
    this.contactPhone,
    this.address,
    this.appliedLocationId,
    this.location,
  });
}
