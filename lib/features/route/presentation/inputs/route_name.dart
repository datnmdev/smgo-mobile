import 'package:formz/formz.dart';

enum RouteNameValidationError { empty }

class RouteNameInput extends FormzInput<String, RouteNameValidationError> {
  const RouteNameInput.pure() : super.pure('');
  const RouteNameInput.dirty([super.value = '']) : super.dirty();

  @override
  RouteNameValidationError? validator(String value) {
    if (value.isEmpty) {
      return RouteNameValidationError.empty;
    }
    return null;
  }
}
