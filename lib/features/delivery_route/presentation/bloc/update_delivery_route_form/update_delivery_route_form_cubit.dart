import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/update_delivery_route_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/update_delivery_route_form/update_delivery_route_form_state.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/route_name_input.dart';

class UpdateDeliveryRouteFormCubit extends Cubit<UpdateDeliveryRouteFormState> {
  final UpdateDeliveryRouteUsecase updateDeliveryRouteUsecase;

  UpdateDeliveryRouteFormCubit({required this.updateDeliveryRouteUsecase})
    : super(const UpdateDeliveryRouteFormInitial());

  void reset() {
    emit(state.copyWith(routeNameInput: RouteNameInput.pure()));
  }

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
      emit(UpdateDeliveryRouteFormLoading(state: state));
      final dataState = await updateDeliveryRouteUsecase.call(
        params: UpdateDeliveryRouteUsecaseParams(
          name: state.routeNameInput.value,
          deliveryRouteId: routeId,
        ),
      );
      if (dataState is DataSuccess) {
        emit(UpdateDeliveryRouteFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(
          UpdateDeliveryRouteFormFailed(error: dataState.error!, state: state),
        );
      }
    }
  }
}
