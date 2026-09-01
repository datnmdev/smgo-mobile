import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_completed/transition_route_to_completed_state.dart';

class TransitionRouteToCompletedCubit
    extends Cubit<TransitionRouteToCompletedState> {
  final UpdateDeliveryRouteUsecase updateDeliveryRouteUsecase;

  TransitionRouteToCompletedCubit({required this.updateDeliveryRouteUsecase})
    : super(const TransitionRouteToCompletedInitial());

  void call({required String deliveryRouteId}) async {
    emit(const TransitionRouteToCompletedLoading());
    final dataState = await updateDeliveryRouteUsecase.call(
      params: UpdateDeliveryRouteUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        status: 'completed',
      ),
    );
    if (dataState is DataSuccess) {
      emit(TransitionRouteToCompletedDone());
    } else if (dataState is DataFailed) {
      emit(TransitionRouteToCompletedFailed(error: dataState.error!));
    }
  }
}
