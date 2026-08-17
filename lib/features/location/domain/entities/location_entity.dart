import 'package:shipgo/features/location/domain/entities/media_entity.dart';
import 'package:shipgo/features/location/domain/entities/point_entity.dart';

class LocationEntity {
  final String id;
  final String locationName;
  final String contactName;
  final String contactPhone;
  final List<MediaEntity> media;
  final String? note;
  final String address;
  final PointEntity? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocationEntity({
    required this.id,
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    required this.media,
    this.note,
    required this.address,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });
}
