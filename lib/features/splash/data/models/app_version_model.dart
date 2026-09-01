import 'package:json_annotation/json_annotation.dart';
import 'package:smgo/features/splash/domain/entities/app_version_entity.dart';

part 'app_version_model.g.dart';

@JsonSerializable()
class AppVersionModel extends AppVersionEntity {
  const AppVersionModel({
    required super.id,
    required super.platform,
    required super.versionName,
    required super.buildNumber,
    required super.minSupportedBuild,
    super.storeAppId,
    required super.isMaintenance,
    super.maintenanceMessage,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) =>
      _$AppVersionModelFromJson(json);
}
