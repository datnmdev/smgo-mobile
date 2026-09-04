import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/data/data_sources/subscription_api_service.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/domain/repository/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionApiService subscriptionApiService;

  SubscriptionRepositoryImpl({required this.subscriptionApiService});

  @override
  Future<DataState<SubscriptionEntity>> getCurrentSubscription() async {
    try {
      final httpResponse = await subscriptionApiService
          .getCurrentSubscription();
      final subscriptionModel = httpResponse.data.data!;
      return DataSuccess(
        SubscriptionEntity(
          id: subscriptionModel.id,
          status: subscriptionModel.status,
          productId: subscriptionModel.productId,
          startsAt: subscriptionModel.startsAt,
          expiresAt: subscriptionModel.expiresAt,
          autoRenew: subscriptionModel.autoRenew,
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> verifySubscription({
    required String platform,
    required String purchaseToken,
  }) async {
    try {
      final httpResponse = await subscriptionApiService.verify(
        body: VerifySubscriptionBodyRequest(
          platform: platform,
          purchaseToken: purchaseToken,
        ),
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
