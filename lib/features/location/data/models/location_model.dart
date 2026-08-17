import 'package:json_annotation/json_annotation.dart';
import 'package:shipgo/features/location/data/models/media_model.dart';
import 'package:shipgo/features/location/data/models/point_model.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final String id;
  final String locationName;
  final String contactName;
  final String contactPhone;
  @JsonKey(defaultValue: [])
  final List<MediaModel> media;
  final String? note;
  final String address;
  final PointModel? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocationModel({
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

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}
