import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/location/domain/usecases/delete_locations_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_state.dart';

class DeleteLocationsCubit extends Cubit<DeleteLocationsState> {
  final DeleteLocationsUsecase deleteLocationsUsecase;

  DeleteLocationsCubit({required this.deleteLocationsUsecase})
    : super(const DeleteLocationsInitial());

  Future<void> call({required List<String> locationIds}) async {
    emit(const DeleteLocationsLoading());
    final dataState = await deleteLocationsUsecase.call(
      params: DeleteLocationsParams(locationIds: locationIds),
    );
    if (dataState is DataSuccess) {
      emit(const DeleteLocationsDone());
    } else if (dataState is DataFailed) {
      emit(DeleteLocationsFailed(error: dataState.error!));
    }
  }
}
