import 'package:json_annotation/json_annotation.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel {
  final String id;
  final String url;

  MediaModel({required this.id, required this.url});

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);
}
