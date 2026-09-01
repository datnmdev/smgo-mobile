import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/delete_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_state.dart';

class DeleteDeliveryRoutesCubit extends Cubit<DeleteDeliveryRoutesState> {
  final DeleteDeliveryRoutesUsecase deleteDeliveryRoutesUsecase;

  DeleteDeliveryRoutesCubit({required this.deleteDeliveryRoutesUsecase})
    : super(const DeleteDeliveryRoutesInitial());

  Future<void> call(List<String> routeIds) async {
    emit(const DeleteDeliveryRoutesLoading());
    final dataState = await deleteDeliveryRoutesUsecase.call(
      params: DeleteDeliveryRoutesUsecaseParams(deliveryRouteIds: routeIds),
    );
    if (dataState is DataSuccess) {
      emit(const DeleteDeliveryRoutesDone());
    } else if (dataState is DataFailed) {
      print((dataState.error as DioException).response?.data);
      emit(DeleteDeliveryRoutesFailed(error: dataState.error!));
    }
  }
}
