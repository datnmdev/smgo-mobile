// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extracted_order_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtractedOrderInfoModel _$ExtractedOrderInfoModelFromJson(
  Map<String, dynamic> json,
) => ExtractedOrderInfoModel(
  orderCode: json['orderCode'] as String,
  orderName: json['orderName'] as String,
  contactName: json['contactName'] as String,
  contactPhone: json['contactPhone'] as String,
  address: json['address'] as String,
);

Map<String, dynamic> _$ExtractedOrderInfoModelToJson(
  ExtractedOrderInfoModel instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'orderName': instance.orderName,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
};
