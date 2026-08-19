// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  id: json['id'] as String,
  name: json['name'] as String,
  status: json['status'] as String,
  totalOrders: (json['totalOrders'] as num).toInt(),
  totalCanceledOrders: (json['totalCanceledOrders'] as num).toInt(),
  totalCheckedOrders: (json['totalCheckedOrders'] as num).toInt(),
  totalPendingOrders: (json['totalPendingOrders'] as num).toInt(),
  totalRescheduledOrders: (json['totalRescheduledOrders'] as num).toInt(),
  totalDeliveredOrders: (json['totalDeliveredOrders'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'totalOrders': instance.totalOrders,
      'totalPendingOrders': instance.totalPendingOrders,
      'totalCheckedOrders': instance.totalCheckedOrders,
      'totalDeliveredOrders': instance.totalDeliveredOrders,
      'totalCanceledOrders': instance.totalCanceledOrders,
      'totalRescheduledOrders': instance.totalRescheduledOrders,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
