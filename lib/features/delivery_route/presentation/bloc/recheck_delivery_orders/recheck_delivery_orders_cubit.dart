import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/recheck_delivery_orders_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/recheck_delivery_orders/recheck_delivery_orders_state.dart';

class RecheckDeliveryOrdersCubit extends Cubit<RecheckDeliveryOrdersState> {
  final RecheckDeliveryOrdersUsecase recheckDeliveryOrdersUsecase;

  RecheckDeliveryOrdersCubit({required this.recheckDeliveryOrdersUsecase})
    : super(RecheckDeliveryOrdersInitial());

  void call({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    emit(const RecheckDeliveryOrdersLoading());
    final dataState = await recheckDeliveryOrdersUsecase.call(
      params: RecheckDeliveryOrdersUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderIds: deliveryOrderIds,
      ),
    );
    if (dataState is DataSuccess) {
      emit(RecheckDeliveryOrdersDone());
    } else if (dataState is DataFailed) {
      emit(RecheckDeliveryOrdersFailed(error: dataState.error!));
    }
  }
}
