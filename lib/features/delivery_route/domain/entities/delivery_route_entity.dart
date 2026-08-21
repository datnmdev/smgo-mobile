import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';

class DeliveryRouteEntity {
  final String id;
  final String name;
  final String status;
  final int totalOrders;
  final int totalPendingOrders;
  final int totalCheckedOrders;
  final int totalDeliveredOrders;
  final int totalCancelledOrders;
  final int totalRescheduledOrders;
  final List<DeliveryOrderEntity> orders;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryRouteEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.totalOrders,
    required this.totalCancelledOrders,
    required this.totalCheckedOrders,
    required this.totalPendingOrders,
    required this.totalRescheduledOrders,
    required this.totalDeliveredOrders,
    this.orders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalSortedOrders {
    return orders.where((order) => order.sequenceOrder != null).length;
  }

  double get checkProgress {
    if (totalOrders == 0) return 0;
    return totalCheckedOrders / totalOrders;
  }

  double get sortingProgress {
    if (totalOrders == 0) return 0;
    return totalSortedOrders / totalOrders;
  }

  double get deliveryProgress {
    if (totalOrders == 0) return 0;
    return (totalDeliveredOrders +
            totalCancelledOrders +
            totalRescheduledOrders) /
        totalOrders;
  }

  bool get isAllChecked => totalCheckedOrders == totalOrders;

  bool get isAllSorted => totalSortedOrders == totalOrders;

  bool get isCompleted => status == DeliveryRouteStatus.completed.value;
}

enum DeliveryRouteStatus {
  pending(value: 'pending'),
  sorting(value: 'sorting'),
  delivering(value: 'delivering'),
  completed(value: 'completed');

  final String value;
  const DeliveryRouteStatus({required this.value});
}
