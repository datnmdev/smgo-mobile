import 'package:shipgo/shared/domain/entities/point_entity.dart';

class InititalAddLocationFormEntity {
  final String locationName;
  final String contactName;
  final String contactPhone;
  final String? note;
  final String address;
  final PointEntity location;

  InititalAddLocationFormEntity({
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.location,
    this.note,
  });
}
