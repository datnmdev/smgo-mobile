import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/sort_delivery_orders_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/sort_delivery_orders/sort_delivery_orders_state.dart';

class SortDeliveryOrdersCubit extends Cubit<SortDeliveryOrdersState> {
  final SortDeliveryOrdersUsecase sortDeliveryOrdersUsecase;

  SortDeliveryOrdersCubit({required this.sortDeliveryOrdersUsecase})
    : super(SortDeliveryOrdersInitial());

  void call({
    required String deliveryRouteId,
  }) async {
    emit(const SortDeliveryOrdersLoading());
    final dataState = await sortDeliveryOrdersUsecase.call(
      params: SortDeliveryOrdersUsecaseParams(deliveryRouteId: deliveryRouteId),
    );
    if (dataState is DataSuccess) {
      emit(SortDeliveryOrdersDone());
    } else if (dataState is DataFailed) {
      emit(SortDeliveryOrdersFailed(error: dataState.error!));
    }
  }
}
