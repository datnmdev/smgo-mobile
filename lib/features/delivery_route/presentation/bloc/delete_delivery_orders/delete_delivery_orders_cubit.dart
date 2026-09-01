import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/delete_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_state.dart';

class DeleteDeliveryOrdersCubit extends Cubit<DeleteDeliveryOrdersState> {
  final DeleteDeliveryOrdersUsecase deleteDeliveryOrdersUsecase;

  DeleteDeliveryOrdersCubit({required this.deleteDeliveryOrdersUsecase})
    : super(const DeleteDeliveryOrdersInitial());

  Future<void> call({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    emit(const DeleteDeliveryOrdersLoading());
    final dataState = await deleteDeliveryOrdersUsecase.call(
      params: DeleteDeliveryOrdersUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderIds: deliveryOrderIds,
      ),
    );
    if (dataState is DataSuccess) {
      emit(const DeleteDeliveryOrdersDone());
    } else if (dataState is DataFailed) {
      print(deliveryOrderIds);
      print((dataState.error as DioException).response?.data);
      emit(DeleteDeliveryOrdersFailed(error: dataState.error!));
    }
  }
}
