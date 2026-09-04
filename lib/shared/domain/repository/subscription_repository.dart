import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<DataState<SubscriptionEntity>> getCurrentSubscription();
  Future<DataState<bool>> verifySubscription({
    required String platform,
    required String purchaseToken,
  });
}
