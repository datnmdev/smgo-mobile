import 'package:formz/formz.dart';

enum ContactPhoneValidationError { empty, invalid }

class ContactPhone extends FormzInput<String, ContactPhoneValidationError> {
  const ContactPhone.pure([super.value = '']) : super.pure();
  const ContactPhone.dirty([super.value = '']) : super.dirty();

  static final RegExp _phoneRegExp = RegExp(
    r'^(?:(\+84|0)(?:3[2-9]|5[2689]|7[0|6-9]|8[1-9]|9[0-4|6-9][0-9]{7}|[1-9][0-9]{1,2}[0-9]{7,8})|\+?[1-9]\d{1,14})$',
  );

  @override
  ContactPhoneValidationError? validator(String value) {
    if (value.isEmpty) {
      return ContactPhoneValidationError.empty;
    } else if (!_phoneRegExp.hasMatch(value)) {
      return ContactPhoneValidationError.invalid;
    }
    return null;
  }
}
