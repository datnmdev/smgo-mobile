import 'dart:convert';

class OrderInfo {
  final String orderCode;
  final String orderName;
  final String contactName;
  final String contactPhone;
  final String address;

  const OrderInfo({
    required this.orderCode,
    required this.orderName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      orderCode: json['orderCode']?.toString().trim() ?? '',
      orderName: json['orderName']?.toString().trim() ?? '',
      contactName: json['contactName']?.toString().trim() ?? '',
      contactPhone: json['contactPhone']?.toString().trim() ?? '',
      address: json['address']?.toString().trim() ?? '',
    );
  }

  factory OrderInfo.fromLlmOutput(String rawOutput) {
    var cleanJson = rawOutput.trim();
    cleanJson = cleanJson
        .replaceFirst(RegExp(r'^```json\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^```\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
    final startIndex = cleanJson.indexOf('{');
    final endIndex = cleanJson.lastIndexOf('}');
    cleanJson = cleanJson.substring(startIndex, endIndex + 1);
    final decoded = jsonDecode(cleanJson);
    return OrderInfo.fromJson(decoded);
  }

  @override
  String toString() {
    return 'OrderInfo('
        'orderCode: $orderCode, '
        'orderName: $orderName, '
        'contactName: $contactName, '
        'contactPhone: $contactPhone, '
        'address: $address'
        ')';
  }
}
