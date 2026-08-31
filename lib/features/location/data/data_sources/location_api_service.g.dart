// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMyLocationsQuery _$GetMyLocationsQueryFromJson(Map<String, dynamic> json) =>
    GetMyLocationsQuery(
      keyword: json['keyword'] as String?,
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$GetMyLocationsQueryToJson(
  GetMyLocationsQuery instance,
) => <String, dynamic>{
  'keyword': ?instance.keyword,
  'page': ?instance.page,
  'limit': ?instance.limit,
  'id': ?instance.id,
};

LocationBodyRequest _$LocationBodyRequestFromJson(Map<String, dynamic> json) =>
    LocationBodyRequest(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationBodyRequestToJson(
  LocationBodyRequest instance,
) => <String, dynamic>{'x': instance.x, 'y': instance.y};

CreateLocationBodyRequest _$CreateLocationBodyRequestFromJson(
  Map<String, dynamic> json,
) => CreateLocationBodyRequest(
  locationName: json['locationName'] as String,
  contactName: json['contactName'] as String,
  contactPhone: json['contactPhone'] as String,
  address: json['address'] as String,
  mediaIds: (json['mediaIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  note: json['note'] as String?,
  location: json['location'] == null
      ? null
      : LocationBodyRequest.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateLocationBodyRequestToJson(
  CreateLocationBodyRequest instance,
) => <String, dynamic>{
  'locationName': instance.locationName,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
  'mediaIds': instance.mediaIds,
  'note': instance.note,
  'location': instance.location,
};

UpdateLocationBodyRequest _$UpdateLocationBodyRequestFromJson(
  Map<String, dynamic> json,
) => UpdateLocationBodyRequest(
  locationName: json['locationName'] as String?,
  contactName: json['contactName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  address: json['address'] as String?,
  mediaIds: (json['mediaIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  note: json['note'] as String?,
  location: json['location'] == null
      ? null
      : LocationBodyRequest.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpdateLocationBodyRequestToJson(
  UpdateLocationBodyRequest instance,
) => <String, dynamic>{
  'locationName': instance.locationName,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
  'mediaIds': instance.mediaIds,
  'note': instance.note,
  'location': instance.location,
};

DeleteLocationsBodyRequest _$DeleteLocationsBodyRequestFromJson(
  Map<String, dynamic> json,
) => DeleteLocationsBodyRequest(
  locationIds: (json['locationIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DeleteLocationsBodyRequestToJson(
  DeleteLocationsBodyRequest instance,
) => <String, dynamic>{'locationIds': instance.locationIds};

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _LocationApiService implements LocationApiService {
  _LocationApiService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<ApiResponse<Pagination<LocationModel>>>> getMyLocations({
    required GetMyLocationsQuery query,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(query.toJson());
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<HttpResponse<ApiResponse<Pagination<LocationModel>>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/user/locations',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<Pagination<LocationModel>> _value;
    try {
      _value = ApiResponse<Pagination<LocationModel>>.fromJson(
        _result.data!,
        (json) => Pagination<LocationModel>.fromJson(
          json as Map<String, dynamic>,
          (json) => LocationModel.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ApiResponse<dynamic>>> createLocation({
    required CreateLocationBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<HttpResponse<ApiResponse<dynamic>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/user/locations',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<dynamic> _value;
    try {
      _value = ApiResponse<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ApiResponse<dynamic>>> updateLocation({
    required String locationId,
    required UpdateLocationBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<HttpResponse<ApiResponse<dynamic>>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/user/locations/${locationId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<dynamic> _value;
    try {
      _value = ApiResponse<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ApiResponse<dynamic>>> deleteLocations({
    required DeleteLocationsBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<HttpResponse<ApiResponse<dynamic>>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/user/locations/m',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<dynamic> _value;
    try {
      _value = ApiResponse<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
