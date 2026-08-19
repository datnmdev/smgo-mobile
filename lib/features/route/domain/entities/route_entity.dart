class RouteEntity {
  final String id;
  final String name;
  final String status;
  final int totalOrders;
  final int totalPendingOrders;
  final int totalCheckedOrders;
  final int totalDeliveredOrders;
  final int totalCanceledOrders;
  final int totalRescheduledOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.totalOrders,
    required this.totalCanceledOrders,
    required this.totalCheckedOrders,
    required this.totalPendingOrders,
    required this.totalRescheduledOrders,
    required this.totalDeliveredOrders,
    required this.createdAt,
    required this.updatedAt,
  });
}
