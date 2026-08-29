import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/confirm_cancelled_order/confirm_cancelled_order_state.dart';

class ConfirmCancelledOrderCubit extends Cubit<ConfirmCancelledOrderState> {
  final UpdateDeliveryOrderUsecase updateDeliveryOrderUsecase;

  ConfirmCancelledOrderCubit({required this.updateDeliveryOrderUsecase})
    : super(const ConfirmCancelledOrderInitial());

  void call({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    emit(const ConfirmCancelledOrderLoading());
    final dataState = await updateDeliveryOrderUsecase.call(
      params: UpdateDeliveryOrderUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderId: deliveryOrderId,
        status: 'cancelled',
      ),
    );
    if (dataState is DataSuccess) {
      emit(ConfirmCancelledOrderDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmCancelledOrderFailed(error: dataState.error!));
    }
  }
}
