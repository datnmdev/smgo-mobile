class ExtractedOrderInfoEntity {
  final String orderCode;
  final String orderName;
  final String contactName;
  final String contactPhone;
  final String address;

  const ExtractedOrderInfoEntity({
    required this.orderCode,
    required this.orderName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
  });

  factory ExtractedOrderInfoEntity.fromJson(Map<String, dynamic> json) {
    return ExtractedOrderInfoEntity(
      orderCode: json['orderCode']?.toString().trim() ?? '',
      orderName: json['orderName']?.toString().trim() ?? '',
      contactName: json['contactName']?.toString().trim() ?? '',
      contactPhone: json['contactPhone']?.toString().trim() ?? '',
      address: json['address']?.toString().trim() ?? '',
    );
  }
}
