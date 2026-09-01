import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/confirm_sorted_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/confirm_sorted_delivery_orders/confirm_sorted_delivery_orders_state.dart';

class ConfirmSortedDeliveryOrdersCubit
    extends Cubit<ConfirmSortedDeliveryOrdersState> {
  final ConfirmSortedDeliveryOrdersUsecase confirmSortedDeliveryOrdersUsecase;

  ConfirmSortedDeliveryOrdersCubit({
    required this.confirmSortedDeliveryOrdersUsecase,
  }) : super(ConfirmSortedDeliveryOrdersInitial());

  void call({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    emit(const ConfirmSortedDeliveryOrdersLoading());
    final dataState = await confirmSortedDeliveryOrdersUsecase.call(
      params: ConfirmSortedDeliveryOrdersUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderIds: deliveryOrderIds,
      ),
    );
    if (dataState is DataSuccess) {
      emit(ConfirmSortedDeliveryOrdersDone());
    } else if (dataState is DataFailed) {
      emit(ConfirmSortedDeliveryOrdersFailed(error: dataState.error!));
    }
  }
}
