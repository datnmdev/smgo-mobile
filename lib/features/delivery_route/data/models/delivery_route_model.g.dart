// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryRouteModel _$DeliveryRouteModelFromJson(Map<String, dynamic> json) =>
    DeliveryRouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      totalOrders: (json['totalOrders'] as num).toInt(),
      totalCancelledOrders: (json['totalCancelledOrders'] as num).toInt(),
      totalCheckedOrders: (json['totalCheckedOrders'] as num).toInt(),
      totalPendingOrders: (json['totalPendingOrders'] as num).toInt(),
      totalSortedOrders: (json['totalSortedOrders'] as num).toInt(),
      totalRescheduledOrders: (json['totalRescheduledOrders'] as num).toInt(),
      totalDeliveredOrders: (json['totalDeliveredOrders'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map(
                (e) => DeliveryOrderModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DeliveryRouteModelToJson(DeliveryRouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'totalOrders': instance.totalOrders,
      'totalPendingOrders': instance.totalPendingOrders,
      'totalCheckedOrders': instance.totalCheckedOrders,
      'totalSortedOrders': instance.totalSortedOrders,
      'totalDeliveredOrders': instance.totalDeliveredOrders,
      'totalCancelledOrders': instance.totalCancelledOrders,
      'totalRescheduledOrders': instance.totalRescheduledOrders,
      'orders': instance.orders,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
