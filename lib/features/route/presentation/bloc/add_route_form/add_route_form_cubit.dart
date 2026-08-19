import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/route/domain/usecases/add_route_usecase.dart';
import 'package:shipgo/features/route/presentation/bloc/add_route_form/add_route_form_state.dart';
import 'package:shipgo/features/route/presentation/inputs/route_name.dart';

class AddRouteFormCubit extends Cubit<AddRouteFormState> {
  final AddRouteUsecase addRouteUsecase;

  AddRouteFormCubit({required this.addRouteUsecase})
    : super(const AddRouteFormInitial());

  void routeNameInputChanged(String value) {
    emit(state.copyWith(routeNameInput: RouteNameInput.dirty(value)));
  }

  void submit() async {
    emit(
      state.copyWith(
        routeNameInput: RouteNameInput.dirty(state.routeNameInput.value),
      ),
    );
    if (state.isValid) {
      emit(AddRouteFormLoading(state: state));
      final dataState = await addRouteUsecase.call(
        params: AddRouteUsecaseParams(name: state.routeNameInput.value),
      );
      if (dataState is DataSuccess) {
        emit(AddRouteFormDone(state: state));
      } else if (dataState is DataFailed) {
        print((dataState.error as DioException).response!.statusMessage);
        emit(AddRouteFormFailed(error: dataState.error!, state: state));
      }
    }
  }
}
