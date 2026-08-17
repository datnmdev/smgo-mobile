// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_url_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadUrlModel _$UploadUrlModelFromJson(Map<String, dynamic> json) =>
    UploadUrlModel(
      uploadUrl: json['uploadUrl'] as String,
      fileKey: json['fileKey'] as String,
      mediaId: json['mediaId'] as String,
    );

Map<String, dynamic> _$UploadUrlModelToJson(UploadUrlModel instance) =>
    <String, dynamic>{
      'uploadUrl': instance.uploadUrl,
      'fileKey': instance.fileKey,
      'mediaId': instance.mediaId,
    };
