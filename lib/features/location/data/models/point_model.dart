import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'point_model.g.dart';

@JsonSerializable()
class PointModel extends Equatable {
  final double x;
  final double y;

  const PointModel({required this.x, required this.y});

  factory PointModel.fromJson(Map<String, dynamic> json) =>
      _$PointModelFromJson(json);

  @override
  List<Object?> get props => [x, y];
}
