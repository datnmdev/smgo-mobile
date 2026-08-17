import 'package:json_annotation/json_annotation.dart';

part 'upload_url_model.g.dart';

@JsonSerializable()
class UploadUrlModel {
  final String uploadUrl;
  final String fileKey;
  final String mediaId;

  const UploadUrlModel({
    required this.uploadUrl,
    required this.fileKey,
    required this.mediaId,
  });

  factory UploadUrlModel.fromJson(Map<String, dynamic> json) =>
      _$UploadUrlModelFromJson(json);
}
