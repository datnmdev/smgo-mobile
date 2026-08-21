import 'package:formz/formz.dart';

enum ContactNameValidationError { empty }

class ContactName extends FormzInput<String, ContactNameValidationError> {
  const ContactName.pure() : super.pure('');
  const ContactName.dirty([super.value = '']) : super.dirty();

  @override
  ContactNameValidationError? validator(String value) {
    if (value.isEmpty) {
      return ContactNameValidationError.empty;
    }
    return null;
  }
}
