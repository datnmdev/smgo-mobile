import 'package:formz/formz.dart';

enum AddressInputValidationError { empty }

class AddressInput extends FormzInput<String, AddressInputValidationError> {
  const AddressInput.pure([super.value = '']) : super.pure();
  const AddressInput.dirty([super.value = '']) : super.dirty();

  @override
  AddressInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return AddressInputValidationError.empty;
    }
    return null;
  }
}
