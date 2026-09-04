class SubscriptionEntity {
  final String id;
  final String status;
  final String productId;
  final DateTime startsAt;
  final DateTime? expiresAt;
  final bool? autoRenew;

  SubscriptionEntity({
    required this.id,
    required this.status,
    required this.productId,
    required this.startsAt,
    this.expiresAt,
    this.autoRenew,
  });
}

enum ProductId {
  basic(value: 'smgo_basic'),
  standard(value: 'smgo_standard'),
  plus(value: 'smgo_plus'),
  premium(value: 'smgo_premium');

  final String value;

  const ProductId({required this.value});
}

enum SubscriptionStatus {
  active(value: 'ACTIVE'),
  inGracePeriod(value: 'IN_GRACE_PERIOD'),
  canceled(value: 'CANCELED'),
  expired(value: 'EXPIRED'),
  onHold(value: 'ON_HOLD');

  final String value;

  const SubscriptionStatus({required this.value});
}
