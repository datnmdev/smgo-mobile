import 'package:formz/formz.dart';

enum ContactNameInputValidationError { empty }

class ContactNameInput
    extends FormzInput<String, ContactNameInputValidationError> {
  const ContactNameInput.pure([super.value = '']) : super.pure();
  const ContactNameInput.dirty([super.value = '']) : super.dirty();

  @override
  ContactNameInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return ContactNameInputValidationError.empty;
    }
    return null;
  }
}
