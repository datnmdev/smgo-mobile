import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/usecases/get_current_subscription_usecase.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_state.dart';

class GetCurrentPlanCubit extends Cubit<GetCurrentPlanState> {
  final GetCurrentSubscriptionUsecase getCurrentSubscriptionUsecase;

  GetCurrentPlanCubit({required this.getCurrentSubscriptionUsecase})
    : super(const GetCurrentPlanInitital());

  Future<void> call() async {
    emit(const GetCurrentPlanLoading());
    final dataState = await getCurrentSubscriptionUsecase.call(
      params: NoParams(),
    );
    if (dataState is DataSuccess) {
      emit(GetCurrentPlanDone(subscription: dataState.data!));
    } else if (dataState is DataFailed) {
      emit(GetCurrentPlanFailed(error: dataState.error!));
    }
  }
}
