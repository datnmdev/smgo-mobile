import 'package:formz/formz.dart';

enum ContactPhoneInputValidationError { empty, invalid }

class ContactPhoneInput extends FormzInput<String, ContactPhoneInputValidationError> {
  const ContactPhoneInput.pure() : super.pure('');
  const ContactPhoneInput.dirty([super.value = '']) : super.dirty();

  static final RegExp _phoneRegExp = RegExp(
    r'^(?:(\+84|0)(?:3[2-9]|5[2689]|7[0|6-9]|8[1-9]|9[0-4|6-9][0-9]{7}|[1-9][0-9]{1,2}[0-9]{7,8})|\+?[1-9]\d{1,14})$',
  );

  @override
  ContactPhoneInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return ContactPhoneInputValidationError.empty;
    } else if (!_phoneRegExp.hasMatch(value)) {
      return ContactPhoneInputValidationError.invalid;
    }
    return null;
  }
}
