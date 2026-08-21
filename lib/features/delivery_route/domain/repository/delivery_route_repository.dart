import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';

class AddDeliveryRouteParams {
  final String name;

  const AddDeliveryRouteParams({required this.name});
}

class GetDeliveryRoutesParams {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;
  final String? status;

  GetDeliveryRoutesParams({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
    this.status,
  });
}

class UpdateDeliveryRouteParams {
  final String? name;

  UpdateDeliveryRouteParams({this.name});
}

class DeleteDeliveryRouteParams {
  final String id;

  DeleteDeliveryRouteParams({required this.id});
}

class PointParam {
  final double x;
  final double y;

  PointParam({required this.x, required this.y});
}

class AddDeliveryOrderParams {
  final String deliveryRouteId;
  final String orderCode;
  final String orderName;
  final String? orderMediaId;
  final String contactName;
  final String contactPhone;
  final String address;
  final String? appliedLocationId;
  final PointParam location;

  AddDeliveryOrderParams({
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

abstract class DeliveryRouteRepository {
  Future<DataState<Pagination<DeliveryRouteEntity>>> getDeliveryRoutes({
    required GetDeliveryRoutesParams params,
  });
  Future<DataState<dynamic>> addDeliveryRoute({
    required AddDeliveryRouteParams params,
  });
  Future<DataState<dynamic>> updateDeliveryRoute({
    required String id,
    required UpdateDeliveryRouteParams params,
  });
  Future<DataState<dynamic>> deleteDeliveryRoute({
    required DeleteDeliveryRouteParams params,
  });

  // Delivery order
  Future<DataState<dynamic>> addDeliveryOrder({
    required AddDeliveryOrderParams params,
  });
}
