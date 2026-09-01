import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_delivering/transition_route_to_delivering_state.dart';

class TransitionRouteToDeliveringCubit
    extends Cubit<TransitionRouteToDeliveringState> {
  final UpdateDeliveryRouteUsecase updateDeliveryRouteUsecase;

  TransitionRouteToDeliveringCubit({required this.updateDeliveryRouteUsecase})
    : super(const TransitionRouteToDeliveringInitial());

  void call({required String deliveryRouteId}) async {
    emit(const TransitionRouteToDeliveringLoading());
    final dataState = await updateDeliveryRouteUsecase.call(
      params: UpdateDeliveryRouteUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        status: 'delivering',
      ),
    );
    if (dataState is DataSuccess) {
      emit(TransitionRouteToDeliveringDone());
    } else if (dataState is DataFailed) {
      emit(TransitionRouteToDeliveringFailed(error: dataState.error!));
    }
  }
}
