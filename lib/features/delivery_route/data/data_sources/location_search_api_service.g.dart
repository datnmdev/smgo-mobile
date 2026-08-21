// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_search_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetLocationSuggestionsQuery _$GetLocationSuggestionsQueryFromJson(
  Map<String, dynamic> json,
) => GetLocationSuggestionsQuery(
  pageNumber: (json['pageNumber'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  contactName: json['contactName'] as String,
  contactPhone: json['contactPhone'] as String,
  address: json['address'] as String,
);

Map<String, dynamic> _$GetLocationSuggestionsQueryToJson(
  GetLocationSuggestionsQuery instance,
) => <String, dynamic>{
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
};

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _LocationSearchApiService implements LocationSearchApiService {
  _LocationSearchApiService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<ApiResponse<Pagination<LocationModel>>>>
  getLocationSuggestions({required GetLocationSuggestionsQuery query}) async {
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
