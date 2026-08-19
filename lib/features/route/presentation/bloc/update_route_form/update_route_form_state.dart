import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/route/presentation/inputs/route_name.dart';

class UpdateMyRouteFormState extends Equatable with FormzMixin {
  final RouteNameInput routeNameInput;

  const UpdateMyRouteFormState({
    this.routeNameInput = const RouteNameInput.pure(),
  });

  UpdateMyRouteFormState.copy(UpdateMyRouteFormState other)
    : routeNameInput = other.routeNameInput;

  UpdateMyRouteFormState copyWith({RouteNameInput? routeNameInput}) {
    return UpdateMyRouteFormState(
      routeNameInput: routeNameInput ?? this.routeNameInput,
    );
  }

  @override
  List<Object?> get props => [routeNameInput];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [routeNameInput];
}

class UpdateMyRouteFormInitial extends UpdateMyRouteFormState {
  const UpdateMyRouteFormInitial();
}

class UpdateMyRouteFormLoading extends UpdateMyRouteFormState {
  UpdateMyRouteFormLoading({required UpdateMyRouteFormState state})
    : super.copy(state);
}

class UpdateMyRouteFormDone extends UpdateMyRouteFormState {
  UpdateMyRouteFormDone({required UpdateMyRouteFormState state})
    : super.copy(state);
}

class UpdateMyRouteFormFailed extends UpdateMyRouteFormState {
  final Object error;

  UpdateMyRouteFormFailed({
    required this.error,
    required UpdateMyRouteFormState state,
  }) : super.copy(state);
}
