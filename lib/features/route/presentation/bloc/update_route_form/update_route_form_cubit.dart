import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/route/domain/usecases/update_my_route_usecase.dart';
import 'package:shipgo/features/route/presentation/bloc/update_route_form/update_route_form_state.dart';
import 'package:shipgo/features/route/presentation/inputs/route_name.dart';

class UpdateMyRouteFormCubit extends Cubit<UpdateMyRouteFormState> {
  final UpdateMyRouteUsecase updateMyRouteUsecase;

  UpdateMyRouteFormCubit({required this.updateMyRouteUsecase})
    : super(const UpdateMyRouteFormInitial());

  void routeNameInputChanged(String value) {
    emit(state.copyWith(routeNameInput: RouteNameInput.dirty(value)));
  }

  void submit(String routeId) async {
    emit(
      state.copyWith(
        routeNameInput: RouteNameInput.dirty(state.routeNameInput.value),
      ),
    );
    if (state.isValid) {
      emit(UpdateMyRouteFormLoading(state: state));
      final dataState = await updateMyRouteUsecase.call(
        params: UpdateMyRouteUsecaseParams(
          name: state.routeNameInput.value,
          id: routeId,
        ),
      );
      if (dataState is DataSuccess) {
        emit(UpdateMyRouteFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(UpdateMyRouteFormFailed(error: dataState.error!, state: state));
      }
    }
  }
}
