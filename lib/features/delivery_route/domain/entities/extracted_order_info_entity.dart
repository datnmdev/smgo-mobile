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
}
