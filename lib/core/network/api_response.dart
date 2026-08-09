import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiError {
  final String code;
  final String message;

  const ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<D> {
  final bool isSuccess;
  final D? data;
  final ApiError? error;

  const ApiResponse({required this.isSuccess, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    D Function(Object? json) fromJsonD,
  ) => _$ApiResponseFromJson(json, fromJsonD);
}
