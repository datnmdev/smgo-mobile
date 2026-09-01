import 'package:formz/formz.dart';

enum LocationNameValidationError { empty }

class LocationName extends FormzInput<String, LocationNameValidationError> {
  const LocationName.pure([super.value = '']) : super.pure();
  const LocationName.dirty([super.value = '']) : super.dirty();

  @override
  LocationNameValidationError? validator(String value) {
    if (value.isEmpty) {
      return LocationNameValidationError.empty;
    }
    return null;
  }
}
