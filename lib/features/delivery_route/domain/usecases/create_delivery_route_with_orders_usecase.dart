import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class CreateDeliveryRouteWithOrdersUsecase
    implements Usecase<DataState<DeliveryRouteEntity>, CreateDeliveryRouteWithOrdersUsecaseParams> {
  final DeliveryRouteRepository deliveryRouteRepository;

  const CreateDeliveryRouteWithOrdersUsecase({
    required this.deliveryRouteRepository,
  });

  @override
  Future<DataState<DeliveryRouteEntity>> call({
    required CreateDeliveryRouteWithOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.createDeliveryRouteWithOrders(
      params: CreateDeliveryRouteWithOrdersParams(
        name: params.name,
        orders: params.orders
            .map(
              (order) => DeliveryOrderParams(
                orderCode: order.orderCode,
                orderName: order.orderName,
                orderMediaId: order.orderMediaId,
                contactName: order.contactName,
                contactPhone: order.contactPhone,
                address: order.address,
                location: PointParam(x: order.location.x, y: order.location.y),
                appliedLocationId: order.appliedLocationId,
              ),
            )
            .toList(),
      ),
    );
  }
}

class CreateDeliveryRouteWithOrdersUsecaseOrdersParam {
  final String orderCode;
  final String? orderName;
  final String? orderMediaId;
  final String contactName;
  final String contactPhone;
  final String address;
  final String? appliedLocationId;
  final Point location;

  CreateDeliveryRouteWithOrdersUsecaseOrdersParam({
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

class CreateDeliveryRouteWithOrdersUsecaseParams {
  final String name;
  final List<CreateDeliveryRouteWithOrdersUsecaseOrdersParam> orders;

  const CreateDeliveryRouteWithOrdersUsecaseParams({
    required this.name,
    required this.orders,
  });
}
