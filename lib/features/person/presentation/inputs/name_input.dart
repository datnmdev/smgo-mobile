import 'package:formz/formz.dart';

enum NameInputValidationError { empty }

class NameInput extends FormzInput<String, NameInputValidationError> {
  const NameInput.pure([super.value = '']) : super.pure();
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  NameInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return NameInputValidationError.empty;
    }
    return null;
  }
}
