// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      id: json['id'] as String,
      locationName: json['locationName'] as String,
      contactName: json['contactName'] as String,
      contactPhone: json['contactPhone'] as String,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      note: json['note'] as String?,
      address: json['address'] as String,
      location: PointModel.fromJson(json['location'] as Map<String, dynamic>),
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationName': instance.locationName,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'media': instance.media,
      'note': instance.note,
      'address': instance.address,
      'location': instance.location,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
