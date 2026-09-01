import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/transition_route_to_sorting/transition_route_to_sorting_state.dart';

class TransitionRouteToSortingCubit
    extends Cubit<TransitionRouteToSortingState> {
  final UpdateDeliveryRouteUsecase updateDeliveryRouteUsecase;

  TransitionRouteToSortingCubit({required this.updateDeliveryRouteUsecase})
    : super(const TransitionRouteToSortingInitial());

  void call({required String deliveryRouteId}) async {
    emit(const TransitionRouteToSortingLoading());
    final dataState = await updateDeliveryRouteUsecase.call(
      params: UpdateDeliveryRouteUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        status: 'sorting',
      ),
    );
    if (dataState is DataSuccess) {
      emit(TransitionRouteToSortingDone());
    } else if (dataState is DataFailed) {
      emit(TransitionRouteToSortingFailed(error: dataState.error!));
    }
  }
}
