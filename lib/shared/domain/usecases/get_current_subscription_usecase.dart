import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/domain/repository/subscription_repository.dart';

class GetCurrentSubscriptionUsecase
    implements Usecase<DataState<SubscriptionEntity>, NoParams> {
  final SubscriptionRepository subscriptionRepository;

  GetCurrentSubscriptionUsecase({required this.subscriptionRepository});

  @override
  Future<DataState<SubscriptionEntity>> call({required NoParams params}) {
    return subscriptionRepository.getCurrentSubscription();
  }
}
