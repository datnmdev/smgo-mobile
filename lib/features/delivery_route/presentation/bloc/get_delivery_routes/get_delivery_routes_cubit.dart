import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';

class GetDeliveryRoutesCubit extends Cubit<GetDeliveryRoutesState> {
  final GetDeliveryRoutesUsecase getDeliveryRoutesUsecase;

  GetDeliveryRoutesCubit({required this.getDeliveryRoutesUsecase})
    : super(const GetDeliveryRoutesInitial());

  Future<void> call({required GetDeliveryRoutesUsecaseParams params}) async {
    emit(
      GetDeliveryRoutesLoading(
        isFirstLoad: state.isFirstLoad,
        routes: state.routes,
      ),
    );
    final dataState = await getDeliveryRoutesUsecase.call(params: params);
    if (dataState is DataSuccess) {
      emit(
        GetDeliveryRoutesDone(
          routes: dataState.data!.data,
          isFirstLoad: state.isFirstLoad && false,
        ),
      );
    } else if (dataState is DataFailed) {
      emit(
        GetDeliveryRoutesFailed(
          routes: state.routes,
          error: dataState.error!,
          isFirstLoad: state.isFirstLoad && false,
        ),
      );
    }
  }
}
