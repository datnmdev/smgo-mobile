import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionPurchaseStatus {
  initial,
  loading,
  loaded,
  purchasing,
  success,
  error,
}

const _absent = Object();

class SubscriptionPurchaseState {
  final SubscriptionPurchaseStatus status;
  final List<ProductDetails> products;
  final Object? error;
  final String? verifiedProductId;
  final bool isRestoredPurchase;
  final bool isPaymentFlowActive;

  SubscriptionPurchaseState({
    this.status = SubscriptionPurchaseStatus.initial,
    this.products = const [],
    this.error,
    this.verifiedProductId,
    this.isRestoredPurchase = false,
    this.isPaymentFlowActive = false,
  });

  SubscriptionPurchaseState copyWith({
    SubscriptionPurchaseStatus? status,
    List<ProductDetails>? products,
    Object? error = _absent,
    String? verifiedProductId,
    bool? isRestoredPurchase,
    bool? isPaymentFlowActive,
  }) {
    return SubscriptionPurchaseState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error == _absent ? this.error : error,
      verifiedProductId: verifiedProductId ?? this.verifiedProductId,
      isRestoredPurchase: isRestoredPurchase ?? this.isRestoredPurchase,
      isPaymentFlowActive: isPaymentFlowActive ?? this.isPaymentFlowActive,
    );
  }
}
