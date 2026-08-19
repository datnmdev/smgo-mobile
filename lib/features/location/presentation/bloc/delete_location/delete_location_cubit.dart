import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/domain/usecases/delete_location_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/delete_location/delete_location_state.dart';

class DeleteLocationCubit extends Cubit<DeleteLocationState> {
  final DeleteLocationUsecase deleteLocationUsecase;

  DeleteLocationCubit({required this.deleteLocationUsecase})
    : super(const DeleteLocationInitial());

  Future<void> call(String locationId) async {
    emit(const DeleteLocationLoading());
    final dataState = await deleteLocationUsecase.call(
      params: DeleteLocationParams(locationId: locationId),
    );
    if (dataState is DataSuccess) {
      emit(const DeleteLocationDone());
    } else if (dataState is DataFailed) {
      emit(DeleteLocationFailed(error: dataState.error!));
    }
  }
}
