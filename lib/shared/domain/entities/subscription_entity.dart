class SubscriptionEntity {
  final String id;
  final String status;
  final String productId;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool autoRenew;

  SubscriptionEntity({
    required this.id,
    required this.status,
    required this.productId,
    required this.startsAt,
    required this.expiresAt,
    required this.autoRenew,
  });
}

enum ProductId {
  basic(value: 'smgo-basic'),
  standard(value: 'smgo-standard'),
  plus(value: 'smgo-plus'),
  premium(value: 'smgo-premium');

  final String value;

  const ProductId({required this.value});
}
