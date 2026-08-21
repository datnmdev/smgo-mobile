import 'package:json_annotation/json_annotation.dart';

part 'delivery_order_model.g.dart';

@JsonSerializable()
class DeliveryOrderModel {
  final String id;
  final String? orderMediaUrl;
  final String orderCode;
  final String orderName;
  final int? sequenceOrder;
  final String status;
  final String contactName;
  final String contactPhone;
  final String address;
  final Point location;
  final String? appliedLocation;
  final DateTime createdAt;
  final DateTime? checkedAt;
  final DateTime? deliveringAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;
  final DateTime updatedAt;

  const DeliveryOrderModel({
    required this.id,
    this.orderMediaUrl,
    required this.orderCode,
    required this.orderName,
    this.sequenceOrder,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.location,
    this.appliedLocation,
    required this.createdAt,
    this.checkedAt,
    this.deliveringAt,
    this.deliveredAt,
    this.cancelledAt,
    this.rescheduledAt,
    required this.updatedAt,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOrderModelFromJson(json);
}

@JsonSerializable()
class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
}
