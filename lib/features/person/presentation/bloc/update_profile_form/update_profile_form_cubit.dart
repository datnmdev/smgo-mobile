import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/person/presentation/inputs/name_input.dart';
import 'package:smgo/shared/domain/usecases/update_profile_usecase.dart';
import 'package:smgo/features/person/presentation/bloc/update_profile_form/update_profile_form_state.dart';

class UpdateProfileFormCubit extends Cubit<UpdateProfileFormState> {
  final UpdateProfileUsecase updateProfileUsecase;

  UpdateProfileFormCubit({required this.updateProfileUsecase})
    : super(UpdateProfileFormInitial());

  void nameInputChanged(String value) {
    emit(state.copyWith(nameInput: NameInput.dirty(value)));
  }

  void avatarChanged(String? value) {
    emit(state.copyWith(avatar: value));
  }

  Future<void> submit() async {
    emit(
      state.copyWith(
        nameInput: NameInput.dirty(state.nameInput.value),
        avatar: state.avatar,
      ),
    );
    if (state.isValid) {
      emit(UpdateProfileFormLoading(state: state));
      final dataState = await updateProfileUsecase.call(
        params: UpdateProfileUsecaseParams(
          name: state.nameInput.value,
          avatar: state.avatar,
        ),
      );
      if (dataState is DataSuccess) {
        emit(UpdateProfileFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(UpdateProfileFormFailed(error: dataState.error!, state: state));
      }
    }
  }
}
