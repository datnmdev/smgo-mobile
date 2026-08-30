class DeliveryOrderEntity {
  final String id;
  final String? orderMediaId;
  final String? orderMediaUrl;
  final String orderCode;
  final String? orderName;
  final int? sequenceOrder;
  final String status;
  final String contactName;
  final String contactPhone;
  final String address;
  final Point location;
  final String? appliedLocationId;
  final String deliveryRouteId;
  final DateTime createdAt;
  final DateTime? checkedAt;
  final DateTime? sortedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;
  final DateTime updatedAt;

  const DeliveryOrderEntity({
    required this.id,
    this.orderMediaId,
    this.orderMediaUrl,
    required this.orderCode,
    this.orderName,
    this.sequenceOrder,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.location,
    this.appliedLocationId,
    required this.deliveryRouteId,
    required this.createdAt,
    this.checkedAt,
    this.sortedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.rescheduledAt,
    required this.updatedAt,
  });
}

enum DeliveryOrderStatus {
  pending(value: 'pending'),
  checked(value: 'checked'),
  sorted(value: 'sorted'),
  delivering(value: 'delivering'), // Chỉ phục vụ mục đích hiển thị
  delivered(value: 'delivered'),
  cancelled(value: 'cancelled'),
  rescheduled(value: 'rescheduled');

  final String value;

  const DeliveryOrderStatus({required this.value});
}

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});
}
