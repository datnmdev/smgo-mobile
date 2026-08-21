import 'package:formz/formz.dart';

enum AddressValidationError { empty }

class Address extends FormzInput<String, AddressValidationError> {
  const Address.pure() : super.pure('');
  const Address.dirty([super.value = '']) : super.dirty();

  @override
  AddressValidationError? validator(String value) {
    if (value.isEmpty) {
      return AddressValidationError.empty;
    }
    return null;
  }
}
