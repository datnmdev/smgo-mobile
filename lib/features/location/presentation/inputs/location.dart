import 'package:formz/formz.dart';
import 'package:smgo/shared/domain/entities/point_entity.dart';

enum LocationValidationError { empty }

class Location extends FormzInput<PointEntity?, LocationValidationError> {
  const Location.pure([super.value]) : super.pure();
  const Location.dirty([super.value]) : super.dirty();

  @override
  LocationValidationError? validator(PointEntity? value) {
    if (value == null) {
      return LocationValidationError.empty;
    }
    return null;
  }
}
