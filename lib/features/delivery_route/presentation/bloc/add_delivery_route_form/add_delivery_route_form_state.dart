import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/route_name_input.dart';

class AddDeliveryRouteFormState extends Equatable with FormzMixin {
  final RouteNameInput routeNameInput;

  const AddDeliveryRouteFormState({this.routeNameInput = const RouteNameInput.pure()});

  AddDeliveryRouteFormState.copy(AddDeliveryRouteFormState other)
    : routeNameInput = other.routeNameInput;

  AddDeliveryRouteFormState copyWith({RouteNameInput? routeNameInput}) {
    return AddDeliveryRouteFormState(
      routeNameInput: routeNameInput ?? this.routeNameInput,
    );
  }

  @override
  List<Object?> get props => [routeNameInput];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [routeNameInput];
}

class AddDeliveryRouteFormInitial extends AddDeliveryRouteFormState {
  const AddDeliveryRouteFormInitial();
}

class AddDeliveryRouteFormLoading extends AddDeliveryRouteFormState {
  AddDeliveryRouteFormLoading({required AddDeliveryRouteFormState state}) : super.copy(state);
}

class AddDeliveryRouteFormDone extends AddDeliveryRouteFormState {
  AddDeliveryRouteFormDone({required AddDeliveryRouteFormState state}) : super.copy(state);
}

class AddDeliveryRouteFormFailed extends AddDeliveryRouteFormState {
  final Object error;

  AddDeliveryRouteFormFailed({required this.error, required AddDeliveryRouteFormState state})
    : super.copy(state);
}
