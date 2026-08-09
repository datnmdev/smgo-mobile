// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) =>
    ApiError(code: json['code'] as String, message: json['message'] as String);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
};

ApiResponse<D> _$ApiResponseFromJson<D>(
  Map<String, dynamic> json,
  D Function(Object? json) fromJsonD,
) => ApiResponse<D>(
  isSuccess: json['isSuccess'] as bool,
  data: _$nullableGenericFromJson(json['data'], fromJsonD),
  error: json['error'] == null
      ? null
      : ApiError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiResponseToJson<D>(
  ApiResponse<D> instance,
  Object? Function(D value) toJsonD,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'data': _$nullableGenericToJson(instance.data, toJsonD),
  'error': instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
