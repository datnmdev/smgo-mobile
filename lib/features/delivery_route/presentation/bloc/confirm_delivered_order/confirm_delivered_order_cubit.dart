import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivered_order/confirm_delivered_order_state.dart';

class ConfirmDeliveredOrderCubit extends Cubit<ConfirmDeliveredOrderState> {
  final UpdateDeliveryOrderUsecase updateDeliveryOrderUsecase;

  ConfirmDeliveredOrderCubit({required this.updateDeliveryOrderUsecase})
    : super(const ConfirmDeliveredOrderInitial());

  void call({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    emit(const ConfirmDeliveredOrderLoading());
    final dataState = await updateDeliveryOrderUsecase.call(
      params: UpdateDeliveryOrderUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderId: deliveryOrderId,
        status: 'delivered',
      ),
    );
    if (dataState is DataSuccess) {
      emit(ConfirmDeliveredOrderDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmDeliveredOrderFailed(error: dataState.error!));
    }
  }
}
