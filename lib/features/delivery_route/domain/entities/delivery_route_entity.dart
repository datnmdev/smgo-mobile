import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';

class DeliveryRouteEntity {
  final String id;
  final String name;
  final String status;
  final int totalOrders;
  final int totalPendingOrders;
  final int totalCheckedOrders;
  final int totalSortedOrders;
  final int totalDeliveredOrders;
  final int totalCancelledOrders;
  final int totalRescheduledOrders;
  final int? totalDistance;
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
    required this.totalSortedOrders,
    required this.totalRescheduledOrders,
    this.totalDistance,
    required this.totalDeliveredOrders,

    this.orders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

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

  bool get isAllOrdersRouted =>
      orders.where((order) => order.sequenceOrder != null).length ==
      totalOrders;

  DeliveryOrderEntity? get currentNeedSortOrder {
    if (status == 'sorting' && isAllOrdersRouted) {
      var unsortedOrders = orders
          .where((order) => order.status == 'checked')
          .toList();
      var maxSequenceOrderIndex = 0;
      for (int i = 0; i < unsortedOrders.length; ++i) {
        if (unsortedOrders[i].sequenceOrder! >
            unsortedOrders[maxSequenceOrderIndex].sequenceOrder!) {
          maxSequenceOrderIndex = i;
        }
      }
      return unsortedOrders[maxSequenceOrderIndex];
    }
    return null;
  }

  DeliveryOrderEntity? get currentNeedDeliveringOrder {
    if (status == 'delivering' && isAllSorted) {
      var deliveringOrders = orders
          .where((order) => order.status == 'sorted')
          .toList();
      var minSequenceOrderIndex = 0;
      for (int i = 0; i < deliveringOrders.length; ++i) {
        if (deliveringOrders[i].sequenceOrder! <
            deliveringOrders[minSequenceOrderIndex].sequenceOrder!) {
          minSequenceOrderIndex = i;
        }
      }
      return deliveringOrders[minSequenceOrderIndex];
    }
    return null;
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
