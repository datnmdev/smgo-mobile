import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/transition_route_to_pending/transition_route_to_pending_state.dart';

class TransitionRouteToPendingCubit
    extends Cubit<TransitionRouteToPendingState> {
  final UpdateDeliveryRouteUsecase updateDeliveryRouteUsecase;

  TransitionRouteToPendingCubit({required this.updateDeliveryRouteUsecase})
    : super(const TransitionRouteToPendingInitial());

  void call({required String deliveryRouteId}) async {
    emit(const TransitionRouteToPendingLoading());
    final dataState = await updateDeliveryRouteUsecase.call(
      params: UpdateDeliveryRouteUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        status: 'pending',
      ),
    );
    if (dataState is DataSuccess) {
      emit(TransitionRouteToPendingDone());
    } else if (dataState is DataFailed) {
      emit(TransitionRouteToPendingFailed(error: dataState.error!));
    }
  }
}
