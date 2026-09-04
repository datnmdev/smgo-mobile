import 'package:smgo/shared/domain/entities/subscription_entity.dart';

abstract class GetCurrentPlanState {
  const GetCurrentPlanState();
}

class GetCurrentPlanInitital extends GetCurrentPlanState {
  const GetCurrentPlanInitital();
}

class GetCurrentPlanLoading extends GetCurrentPlanState {
  const GetCurrentPlanLoading();
}

class GetCurrentPlanDone extends GetCurrentPlanState {
  final SubscriptionEntity subscription;

  const GetCurrentPlanDone({required this.subscription});
}

class GetCurrentPlanFailed extends GetCurrentPlanState {
  final Object error;

  const GetCurrentPlanFailed({required this.error});
}
