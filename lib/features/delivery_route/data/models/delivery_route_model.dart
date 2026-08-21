import 'package:json_annotation/json_annotation.dart';
import 'package:shipgo/features/delivery_route/data/models/delivery_order_model.dart';

part 'delivery_route_model.g.dart';

@JsonSerializable()
class DeliveryRouteModel {
  final String id;
  final String name;
  final String status;
  final int totalOrders;
  final int totalPendingOrders;
  final int totalCheckedOrders;
  final int totalDeliveredOrders;
  final int totalCancelledOrders;
  final int totalRescheduledOrders;
  final List<DeliveryOrderModel> orders;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryRouteModel({
    required this.id,
    required this.name,
    required this.status,
    required this.totalOrders,
    required this.totalCancelledOrders,
    required this.totalCheckedOrders,
    required this.totalPendingOrders,
    required this.totalRescheduledOrders,
    required this.totalDeliveredOrders,
    required this.createdAt,
    required this.updatedAt,
    this.orders = const [],
  });

  factory DeliveryRouteModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryRouteModelFromJson(json);
}
