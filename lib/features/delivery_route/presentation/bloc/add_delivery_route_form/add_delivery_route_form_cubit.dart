import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/add_delivery_route_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_route_form/add_delivery_route_form_state.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/route_name_input.dart';

class AddDeliveryRouteFormCubit extends Cubit<AddDeliveryRouteFormState> {
  final AddDeliveryRouteUsecase addDeliveryRouteUsecase;

  AddDeliveryRouteFormCubit({required this.addDeliveryRouteUsecase})
    : super(const AddDeliveryRouteFormInitial());

  void reset() {
    emit(state.copyWith(routeNameInput: RouteNameInput.pure()));
  }

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
      emit(AddDeliveryRouteFormLoading(state: state));
      final dataState = await addDeliveryRouteUsecase.call(
        params: AddDeliveryRouteUsecaseParams(name: state.routeNameInput.value),
      );
      if (dataState is DataSuccess) {
        emit(AddDeliveryRouteFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(AddDeliveryRouteFormFailed(error: dataState.error!, state: state));
      }
    }
  }
}
