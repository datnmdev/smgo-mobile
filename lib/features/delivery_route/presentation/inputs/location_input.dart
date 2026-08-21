import 'package:formz/formz.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';

enum LocationInputValidationError { empty }

class LocationInput extends FormzInput<Point?, LocationInputValidationError> {
  const LocationInput.pure() : super.pure(null);
  const LocationInput.dirty([super.value]) : super.dirty();

  @override
  LocationInputValidationError? validator(Point? value) {
    if (value == null) {
      return LocationInputValidationError.empty;
    }
    return null;
  }
}
