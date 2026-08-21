import 'package:formz/formz.dart';

enum OrderNameInputValidationError { empty }

class OrderNameInput extends FormzInput<String, OrderNameInputValidationError> {
  const OrderNameInput.pure() : super.pure('');
  const OrderNameInput.dirty([super.value = '']) : super.dirty();

  @override
  OrderNameInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return OrderNameInputValidationError.empty;
    }
    return null;
  }
}
