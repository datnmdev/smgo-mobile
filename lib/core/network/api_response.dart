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

@JsonSerializable()
class PaginationMeta {
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PaginationMeta({
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true)
class Pagination<T> {
  final T data;
  final PaginationMeta meta;

  const Pagination({required this.data, required this.meta});

  factory Pagination.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginationFromJson(json, fromJsonT);
}
