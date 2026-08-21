import 'package:formz/formz.dart';

enum RouteNameInputValidationError { empty }

class RouteNameInput extends FormzInput<String, RouteNameInputValidationError> {
  const RouteNameInput.pure() : super.pure('');
  const RouteNameInput.dirty([super.value = '']) : super.dirty();

  @override
  RouteNameInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return RouteNameInputValidationError.empty;
    }
    return null;
  }
}
