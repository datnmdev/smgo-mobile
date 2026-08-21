// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOrderModel _$DeliveryOrderModelFromJson(Map<String, dynamic> json) =>
    DeliveryOrderModel(
      id: json['id'] as String,
      orderMediaUrl: json['orderMediaUrl'] as String?,
      orderCode: json['orderCode'] as String,
      orderName: json['orderName'] as String,
      sequenceOrder: (json['sequenceOrder'] as num?)?.toInt(),
      status: json['status'] as String,
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      address: json['address'] as String,
      location: Point.fromJson(json['location'] as Map<String, dynamic>),
      appliedLocation: json['appliedLocation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
      deliveringAt: json['deliveringAt'] == null
          ? null
          : DateTime.parse(json['deliveringAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      rescheduledAt: json['rescheduledAt'] == null
          ? null
          : DateTime.parse(json['rescheduledAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DeliveryOrderModelToJson(DeliveryOrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderMediaUrl': instance.orderMediaUrl,
      'orderCode': instance.orderCode,
      'orderName': instance.orderName,
      'sequenceOrder': instance.sequenceOrder,
      'status': instance.status,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'address': instance.address,
      'location': instance.location,
      'appliedLocation': instance.appliedLocation,
      'createdAt': instance.createdAt.toIso8601String(),
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'deliveringAt': instance.deliveringAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'rescheduledAt': instance.rescheduledAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Point _$PointFromJson(Map<String, dynamic> json) =>
    Point(x: (json['x'] as num).toDouble(), y: (json['y'] as num).toDouble());

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};
