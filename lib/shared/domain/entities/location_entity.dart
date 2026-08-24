import 'package:shipgo/shared/domain/entities/media_entity.dart';
import 'package:shipgo/shared/domain/entities/point_entity.dart';

class LocationEntity {
  final String id;
  final String locationName;
  final String contactName;
  final String contactPhone;
  final List<MediaEntity> media;
  final String? note;
  final String address;
  final PointEntity location;
  final String userId;
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
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
}
