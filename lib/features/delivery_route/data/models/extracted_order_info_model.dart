
import 'package:json_annotation/json_annotation.dart';

part 'extracted_order_info_model.g.dart';

@JsonSerializable()
class ExtractedOrderInfoModel {
  final String orderCode;
  final String orderName;
  final String contactName;
  final String contactPhone;
  final String address;

  const ExtractedOrderInfoModel({
    required this.orderCode,
    required this.orderName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
  });

  factory ExtractedOrderInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ExtractedOrderInfoModelFromJson(json);
}
