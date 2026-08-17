import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_state.dart';

class GetMyLocationsCubit extends Cubit<GetMyLocationsState> {
  final GetMyLocationsUsecase getMyLocationsUsecase;

  GetMyLocationsCubit({required this.getMyLocationsUsecase})
    : super(const GetMyLocationsInitial(data: null));

  Future<void> call(GetMyLocationsParams params) async {
    emit(GetMyLocationsLoading(data: state.data));
    final dataState = await getMyLocationsUsecase.call(params: params);
    if (dataState is DataSuccess) {
      emit(GetMyLocationsDone(data: dataState.data!));
    } else {
      emit(GetMyLocationsFailed(error: dataState.error!, data: state.data));
    }
  }
}
