import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  final String id;
  final String status;
  final String productId;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool autoRenew;

  SubscriptionModel({
    required this.id,
    required this.status,
    required this.productId,
    required this.startsAt,
    required this.expiresAt,
    required this.autoRenew,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
