import 'package:formz/formz.dart';
import 'package:shipgo/features/location/data/models/point_model.dart';

enum LocationValidationError { empty }

class Location extends FormzInput<PointModel?, LocationValidationError> {
  const Location.pure() : super.pure(null);
  const Location.dirty([super.value]) : super.dirty();

  @override
  LocationValidationError? validator(PointModel? value) {
    if (value == null) {
      return LocationValidationError.empty;
    }
    return null;
  }
}
