import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/route_name_input.dart';

class AddRouteFormState extends Equatable with FormzMixin {
  final RouteNameInput routeNameInput;

  const AddRouteFormState({this.routeNameInput = const RouteNameInput.pure()});

  AddRouteFormState.copy(AddRouteFormState other)
    : routeNameInput = other.routeNameInput;

  AddRouteFormState copyWith({RouteNameInput? routeNameInput}) {
    return AddRouteFormState(
      routeNameInput: routeNameInput ?? this.routeNameInput,
    );
  }

  @override
  List<Object?> get props => [routeNameInput];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [routeNameInput];
}

class AddRouteFormInitial extends AddRouteFormState {
  const AddRouteFormInitial();
}

class AddRouteFormLoading extends AddRouteFormState {
  AddRouteFormLoading({required AddRouteFormState state}) : super.copy(state);
}

class AddRouteFormDone extends AddRouteFormState {
  AddRouteFormDone({required AddRouteFormState state}) : super.copy(state);
}

class AddRouteFormFailed extends AddRouteFormState {
  final Object error;

  AddRouteFormFailed({required this.error, required AddRouteFormState state})
    : super.copy(state);
}
