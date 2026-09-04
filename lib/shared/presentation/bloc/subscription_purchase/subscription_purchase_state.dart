import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionPurchaseStatus { initial, loading, loaded, purchasing, success, error }

const _absent = Object();

class SubscriptionPurchaseState {
  final SubscriptionPurchaseStatus status;
  final List<ProductDetails> products;
  final Object? error;

  SubscriptionPurchaseState({
    this.status = SubscriptionPurchaseStatus.initial,
    this.products = const [],
    this.error,
  });

  SubscriptionPurchaseState copyWith({
    SubscriptionPurchaseStatus? status,
    List<ProductDetails>? products,
    Object? error = _absent,
  }) {
    return SubscriptionPurchaseState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error == _absent ? this.error : error,
    );
  }
}
