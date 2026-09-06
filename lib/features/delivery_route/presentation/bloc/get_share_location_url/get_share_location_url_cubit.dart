import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_share_location_url_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/get_share_location_url/get_share_location_url_state.dart';

class GetShareLocationUrlCubit extends Cubit<GetShareLocationUrlState> {
  final GetShareLocationUrlUsecase getShareLocationUrlUsecase;

  GetShareLocationUrlCubit({required this.getShareLocationUrlUsecase})
    : super(const GetShareLocationUrlInitial());

  void call({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    emit(const GetShareLocationUrlLoading());
    final dataState = await getShareLocationUrlUsecase.call(
      params: GetShareLocationUrlUsecaseParams(
        deliveryRouteId: deliveryRouteId,
        deliveryOrderId: deliveryOrderId,
      ),
    );
    if (dataState is DataSuccess) {
      emit(GetShareLocationUrlDone(shareLocationUrl: dataState.data!));
    } else if (dataState is DataFailed) {
      emit(GetShareLocationUrlFailed(error: dataState.error!));
    }
  }
}
