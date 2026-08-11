// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionModel _$AppVersionModelFromJson(Map<String, dynamic> json) =>
    AppVersionModel(
      id: json['id'] as String,
      platform: json['platform'] as String,
      versionName: json['versionName'] as String,
      buildNumber: (json['buildNumber'] as num).toInt(),
      minSupportedBuild: (json['minSupportedBuild'] as num).toInt(),
      storeAppId: json['storeAppId'] as String?,
      isMaintenance: json['isMaintenance'] as bool,
      maintenanceMessage: (json['maintenanceMessage'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, e as String)),
    );

Map<String, dynamic> _$AppVersionModelToJson(AppVersionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'versionName': instance.versionName,
      'buildNumber': instance.buildNumber,
      'minSupportedBuild': instance.minSupportedBuild,
      'storeAppId': instance.storeAppId,
      'isMaintenance': instance.isMaintenance,
      'maintenanceMessage': instance.maintenanceMessage,
    };
