import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/repository/subscription_repository.dart';

class VerifySubscriptionUsecase
    implements Usecase<DataState<bool>, VerifySubscriptionUsecaseParams> {
  final SubscriptionRepository subscriptionRepository;

  VerifySubscriptionUsecase({required this.subscriptionRepository});

  @override
  Future<DataState<bool>> call({
    required VerifySubscriptionUsecaseParams params,
  }) {
    return subscriptionRepository.verifySubscription(
      platform: params.platform,
      purchaseToken: params.purchaseToken,
    );
  }
}

class VerifySubscriptionUsecaseParams {
  final String platform;
  final String purchaseToken;

  VerifySubscriptionUsecaseParams({
    required this.platform,
    required this.purchaseToken,
  });
}
