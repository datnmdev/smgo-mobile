import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/confirm_delivery_order/confirm_delivery_order_state.dart';

class ConfirmDeliveryOrderCubit extends Cubit<ConfirmDeliveryOrderState> {
  final UpdateDeliveryOrderUsecase updateDeliveryOrderUsecase;

  ConfirmDeliveryOrderCubit({required this.updateDeliveryOrderUsecase})
    : super(const ConfirmDeliveryOrderInitial());

  void call({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    emit(const ConfirmDeliveryOrderLoading());
    final dataState = await updateDeliveryOrderUsecase.call(
      params: UpdateDeliveryOrderUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderId: deliveryOrderId,
        status: 'checked',
      ),
    );
    if (dataState is DataSuccess) {
      emit(const ConfirmDeliveryOrderDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmDeliveryOrderFailed(error: dataState.error!));
    }
  }
}
