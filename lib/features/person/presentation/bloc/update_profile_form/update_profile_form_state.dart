import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:smgo/features/person/presentation/inputs/name_input.dart';

const _absent = Object();

class UpdateProfileFormState extends Equatable with FormzMixin {
  final NameInput nameInput;
  final String? avatar;

  const UpdateProfileFormState({required this.nameInput, this.avatar});

  UpdateProfileFormState.copy(UpdateProfileFormState other)
    : nameInput = other.nameInput,
      avatar = other.avatar;

  UpdateProfileFormState copyWith({
    NameInput? nameInput,
    Object? avatar = _absent,
  }) {
    return UpdateProfileFormState(
      nameInput: nameInput ?? this.nameInput,
      avatar: avatar == _absent ? this.avatar : avatar as String?,
    );
  }

  @override
  List<Object?> get props => [nameInput, avatar];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [nameInput];
}

class UpdateProfileFormInitial extends UpdateProfileFormState {
  UpdateProfileFormInitial() : super(nameInput: NameInput.pure());
}

class UpdateProfileFormLoading extends UpdateProfileFormState {
  UpdateProfileFormLoading({required UpdateProfileFormState state})
    : super.copy(state);
}

class UpdateProfileFormDone extends UpdateProfileFormState {
  UpdateProfileFormDone({required UpdateProfileFormState state})
    : super.copy(state);
}

class UpdateProfileFormFailed extends UpdateProfileFormState {
  final Object error;

  UpdateProfileFormFailed({
    required this.error,
    required UpdateProfileFormState state,
  }) : super.copy(state);
}
