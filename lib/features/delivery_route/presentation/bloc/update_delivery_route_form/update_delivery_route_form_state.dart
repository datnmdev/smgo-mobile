import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/route_name_input.dart';

class UpdateDeliveryRouteFormState extends Equatable with FormzMixin {
  final RouteNameInput routeNameInput;

  const UpdateDeliveryRouteFormState({
    this.routeNameInput = const RouteNameInput.pure(),
  });

  UpdateDeliveryRouteFormState.copy(UpdateDeliveryRouteFormState other)
    : routeNameInput = other.routeNameInput;

  UpdateDeliveryRouteFormState copyWith({RouteNameInput? routeNameInput}) {
    return UpdateDeliveryRouteFormState(
      routeNameInput: routeNameInput ?? this.routeNameInput,
    );
  }

  @override
  List<Object?> get props => [routeNameInput];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [routeNameInput];
}

class UpdateDeliveryRouteFormInitial extends UpdateDeliveryRouteFormState {
  const UpdateDeliveryRouteFormInitial();
}

class UpdateDeliveryRouteFormLoading extends UpdateDeliveryRouteFormState {
  UpdateDeliveryRouteFormLoading({required UpdateDeliveryRouteFormState state})
    : super.copy(state);
}

class UpdateDeliveryRouteFormDone extends UpdateDeliveryRouteFormState {
  UpdateDeliveryRouteFormDone({required UpdateDeliveryRouteFormState state})
    : super.copy(state);
}

class UpdateDeliveryRouteFormFailed extends UpdateDeliveryRouteFormState {
  final Object error;

  UpdateDeliveryRouteFormFailed({
    required this.error,
    required UpdateDeliveryRouteFormState state,
  }) : super.copy(state);
}
