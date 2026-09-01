import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/Confirm_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_delivery_orders/confirm_delivery_orders_state.dart';

class ConfirmDeliveryOrdersCubit extends Cubit<ConfirmDeliveryOrdersState> {
  final ConfirmDeliveryOrdersUsecase confirmDeliveryOrdersUsecase;

  ConfirmDeliveryOrdersCubit({required this.confirmDeliveryOrdersUsecase})
    : super(ConfirmDeliveryOrdersInitial());

  void call({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    emit(const ConfirmDeliveryOrdersLoading());
    final dataState = await confirmDeliveryOrdersUsecase.call(
      params: ConfirmDeliveryOrdersUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderIds: deliveryOrderIds,
      ),
    );
    if (dataState is DataSuccess) {
      emit(ConfirmDeliveryOrdersDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmDeliveryOrdersFailed(error: dataState.error!));
    }
  }
}
