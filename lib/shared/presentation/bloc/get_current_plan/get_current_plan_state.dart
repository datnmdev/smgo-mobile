import 'package:smgo/shared/domain/entities/subscription_entity.dart';

abstract class GetCurrentPlanState {
  final SubscriptionEntity? subscription;
  const GetCurrentPlanState({this.subscription});
}

class GetCurrentPlanInitital extends GetCurrentPlanState {
  const GetCurrentPlanInitital();
}

class GetCurrentPlanLoading extends GetCurrentPlanState {
  const GetCurrentPlanLoading();
}

class GetCurrentPlanDone extends GetCurrentPlanState {
  const GetCurrentPlanDone({super.subscription});
}

class GetCurrentPlanFailed extends GetCurrentPlanState {
  final Object error;

  const GetCurrentPlanFailed({required this.error});
}
