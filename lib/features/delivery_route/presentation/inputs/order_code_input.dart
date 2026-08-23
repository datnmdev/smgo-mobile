import 'package:formz/formz.dart';

enum OrderCodeInputValidationError { empty }

class OrderCodeInput extends FormzInput<String, OrderCodeInputValidationError> {
  const OrderCodeInput.pure([super.value = '']) : super.pure();
  const OrderCodeInput.dirty([super.value = '']) : super.dirty();

  @override
  OrderCodeInputValidationError? validator(String value) {
    if (value.isEmpty) {
      return OrderCodeInputValidationError.empty;
    }
    return null;
  }
}
