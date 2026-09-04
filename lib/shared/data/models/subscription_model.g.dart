// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
      status: json['status'] as String,
      productId: json['productId'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      autoRenew: json['autoRenew'] as bool,
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'productId': instance.productId,
      'startsAt': instance.startsAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'autoRenew': instance.autoRenew,
    };
