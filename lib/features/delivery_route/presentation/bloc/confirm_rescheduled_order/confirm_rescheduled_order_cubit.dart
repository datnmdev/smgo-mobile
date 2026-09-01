import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_rescheduled_order/confirm_rescheduled_order_state.dart';

class ConfirmRescheduledOrderCubit extends Cubit<ConfirmRescheduledOrderState> {
  final UpdateDeliveryOrderUsecase updateDeliveryOrderUsecase;

  ConfirmRescheduledOrderCubit({required this.updateDeliveryOrderUsecase})
    : super(const ConfirmRescheduledOrderInitial());

  void call({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    emit(const ConfirmRescheduledOrderLoading());
    final dataState = await updateDeliveryOrderUsecase.call(
      params: UpdateDeliveryOrderUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderId: deliveryOrderId,
        status: 'rescheduled',
      ),
    );
    if (dataState is DataSuccess) {
      emit(ConfirmRescheduledOrderDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmRescheduledOrderFailed(error: dataState.error!));
    }
  }
}
