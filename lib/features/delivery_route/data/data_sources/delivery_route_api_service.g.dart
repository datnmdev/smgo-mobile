// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_route_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetDeliveryRoutesQueryRequest _$GetDeliveryRoutesQueryRequestFromJson(
  Map<String, dynamic> json,
) => GetDeliveryRoutesQueryRequest(
  keyword: json['keyword'] as String?,
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  id: json['id'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$GetDeliveryRoutesQueryRequestToJson(
  GetDeliveryRoutesQueryRequest instance,
) => <String, dynamic>{
  'keyword': ?instance.keyword,
  'pageNumber': ?instance.pageNumber,
  'pageSize': ?instance.pageSize,
  'id': ?instance.id,
  'status': ?instance.status,
};

AddDeliveryRouteBodyRequest _$AddDeliveryRouteBodyRequestFromJson(
  Map<String, dynamic> json,
) => AddDeliveryRouteBodyRequest(name: json['name'] as String);

Map<String, dynamic> _$AddDeliveryRouteBodyRequestToJson(
  AddDeliveryRouteBodyRequest instance,
) => <String, dynamic>{'name': instance.name};

DeliveryOrderRequestData _$DeliveryOrderRequestDataFromJson(
  Map<String, dynamic> json,
) => DeliveryOrderRequestData(
  orderCode: json['orderCode'] as String,
  orderName: json['orderName'] as String?,
  orderMediaId: json['orderMediaId'] as String?,
  contactName: json['contactName'] as String,
  contactPhone: json['contactPhone'] as String,
  address: json['address'] as String,
  appliedLocationId: json['appliedLocationId'] as String?,
  location: PointRequestData.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeliveryOrderRequestDataToJson(
  DeliveryOrderRequestData instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'orderName': ?instance.orderName,
  'orderMediaId': ?instance.orderMediaId,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
  'appliedLocationId': ?instance.appliedLocationId,
  'location': instance.location,
};

CreateDeliveryRouteWithOrdersBodyRequest
_$CreateDeliveryRouteWithOrdersBodyRequestFromJson(Map<String, dynamic> json) =>
    CreateDeliveryRouteWithOrdersBodyRequest(
      name: json['name'] as String,
      orders: (json['orders'] as List<dynamic>)
          .map(
            (e) => DeliveryOrderRequestData.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$CreateDeliveryRouteWithOrdersBodyRequestToJson(
  CreateDeliveryRouteWithOrdersBodyRequest instance,
) => <String, dynamic>{'name': instance.name, 'orders': instance.orders};

UpdateDeliveryRouteBodyRequest _$UpdateDeliveryRouteBodyRequestFromJson(
  Map<String, dynamic> json,
) => UpdateDeliveryRouteBodyRequest(
  name: json['name'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$UpdateDeliveryRouteBodyRequestToJson(
  UpdateDeliveryRouteBodyRequest instance,
) => <String, dynamic>{'name': ?instance.name, 'status': ?instance.status};

PointRequestData _$PointRequestDataFromJson(Map<String, dynamic> json) =>
    PointRequestData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$PointRequestDataToJson(PointRequestData instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

AddDeliveryOrderBodyRequest _$AddDeliveryOrderBodyRequestFromJson(
  Map<String, dynamic> json,
) => AddDeliveryOrderBodyRequest(
  orderCode: json['orderCode'] as String,
  orderName: json['orderName'] as String?,
  orderMediaId: json['orderMediaId'] as String?,
  contactName: json['contactName'] as String,
  contactPhone: json['contactPhone'] as String,
  address: json['address'] as String,
  appliedLocationId: json['appliedLocationId'] as String?,
  location: PointRequestData.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AddDeliveryOrderBodyRequestToJson(
  AddDeliveryOrderBodyRequest instance,
) => <String, dynamic>{
  'orderCode': instance.orderCode,
  'orderName': ?instance.orderName,
  'orderMediaId': ?instance.orderMediaId,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'address': instance.address,
  'appliedLocationId': ?instance.appliedLocationId,
  'location': instance.location,
};

UpdateDeliveryOrderBodyRequest _$UpdateDeliveryOrderBodyRequestFromJson(
  Map<String, dynamic> json,
) => UpdateDeliveryOrderBodyRequest(
  orderCode: json['orderCode'] as String?,
  orderName: json['orderName'] as String?,
  orderMediaId: json['orderMediaId'] as String?,
  status: json['status'] as String?,
  contactName: json['contactName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  address: json['address'] as String?,
  location: json['location'] == null
      ? null
      : PointRequestData.fromJson(json['location'] as Map<String, dynamic>),
  appliedLocationId: json['appliedLocationId'] as String?,
);

Map<String, dynamic> _$UpdateDeliveryOrderBodyRequestToJson(
  UpdateDeliveryOrderBodyRequest instance,
) => <String, dynamic>{
  'orderCode': ?instance.orderCode,
  'orderName': ?instance.orderName,
  'orderMediaId': instance.orderMediaId,
  'status': ?instance.status,
  'contactName': ?instance.contactName,
  'contactPhone': ?instance.contactPhone,
  'address': ?instance.address,
  'location': ?instance.location,
  'appliedLocationId': instance.appliedLocationId,
};

RecheckDeliveryOrdersBodyRequest _$RecheckDeliveryOrdersBodyRequestFromJson(
  Map<String, dynamic> json,
) => RecheckDeliveryOrdersBodyRequest(
  deliveryOrderIds: (json['deliveryOrderIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RecheckDeliveryOrdersBodyRequestToJson(
  RecheckDeliveryOrdersBodyRequest instance,
) => <String, dynamic>{'deliveryOrderIds': instance.deliveryOrderIds};

ConfirmDeliveryOrdersBodyRequest _$ConfirmDeliveryOrdersBodyRequestFromJson(
  Map<String, dynamic> json,
) => ConfirmDeliveryOrdersBodyRequest(
  deliveryOrderIds: (json['deliveryOrderIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ConfirmDeliveryOrdersBodyRequestToJson(
  ConfirmDeliveryOrdersBodyRequest instance,
) => <String, dynamic>{'deliveryOrderIds': instance.deliveryOrderIds};

DeleteDeliveryOrdersBodyRequest _$DeleteDeliveryOrdersBodyRequestFromJson(
  Map<String, dynamic> json,
) => DeleteDeliveryOrdersBodyRequest(
  deliveryOrderIds: (json['deliveryOrderIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DeleteDeliveryOrdersBodyRequestToJson(
  DeleteDeliveryOrdersBodyRequest instance,
) => <String, dynamic>{'deliveryOrderIds': instance.deliveryOrderIds};

SortDeliveryOrdersBodyRequest _$SortDeliveryOrdersBodyRequestFromJson(
  Map<String, dynamic> json,
) => SortDeliveryOrdersBodyRequest(
  source: PointRequestData.fromJson(json['source'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SortDeliveryOrdersBodyRequestToJson(
  SortDeliveryOrdersBodyRequest instance,
) => <String, dynamic>{'source': instance.source};

ConfirmSortedDeliveryOrdersBodyRequest
_$ConfirmSortedDeliveryOrdersBodyRequestFromJson(Map<String, dynamic> json) =>
    ConfirmSortedDeliveryOrdersBodyRequest(
      deliveryOrderIds: (json['deliveryOrderIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ConfirmSortedDeliveryOrdersBodyRequestToJson(
  ConfirmSortedDeliveryOrdersBodyRequest instance,
) => <String, dynamic>{'deliveryOrderIds': instance.deliveryOrderIds};

DeleteDeliveryRoutesBodyRequest _$DeleteDeliveryRoutesBodyRequestFromJson(
  Map<String, dynamic> json,
) => DeleteDeliveryRoutesBodyRequest(
  deliveryRouteIds: (json['deliveryRouteIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DeleteDeliveryRoutesBodyRequestToJson(
  DeleteDeliveryRoutesBodyRequest instance,
) => <String, dynamic>{'deliveryRouteIds': instance.deliveryRouteIds};

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _DeliveryRouteApiService implements DeliveryRouteApiService {
  _DeliveryRouteApiService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<ApiResponse<Pagination<DeliveryRouteModel>>>>
  getDeliveryRoutes({required GetDeliveryRoutesQueryRequest queries}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.addAll(queries.toJson());
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<
          HttpResponse<ApiResponse<Pagination<DeliveryRouteModel>>>
        >(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/delivery-route',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<Pagination<DeliveryRouteModel>> _value;
    try {
      _value = ApiResponse<Pagination<DeliveryRouteModel>>.fromJson(
        _result.data!,
        (json) => Pagination<DeliveryRouteModel>.fromJson(
          json as Map<String, dynamic>,
          (json) => DeliveryRouteModel.fromJson(json as Map<String, dynamic>),
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
  Future<HttpResponse<ApiResponse<dynamic>>> addDeliveryRoute({
    required AddDeliveryRouteBodyRequest body,
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
            '/delivery-route',
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
  Future<HttpResponse<ApiResponse<DeliveryRouteModel>>>
  createDeliveryRouteWithOrders({
    required CreateDeliveryRouteWithOrdersBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<HttpResponse<ApiResponse<DeliveryRouteModel>>>(
          Options(method: 'POST', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/delivery-route/with-orders',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<DeliveryRouteModel> _value;
    try {
      _value = ApiResponse<DeliveryRouteModel>.fromJson(
        _result.data!,
        (json) => DeliveryRouteModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ApiResponse<dynamic>>> updateDeliveryRoute({
    required String id,
    required UpdateDeliveryRouteBodyRequest body,
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
            '/delivery-route/${id}',
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
  Future<HttpResponse<ApiResponse<dynamic>>> deleteDeliveryRoutes({
    required DeleteDeliveryRoutesBodyRequest body,
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
            '/delivery-route/m',
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
  Future<HttpResponse<ApiResponse<dynamic>>> addDeliveryOrder({
    required String deliveryRouteId,
    required AddDeliveryOrderBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order',
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
  Future<HttpResponse<ApiResponse<dynamic>>> updateDeliveryOrder({
    required String deliveryRouteId,
    required String deliveryOrderId,
    required UpdateDeliveryOrderBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/${deliveryOrderId}',
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
  Future<HttpResponse<ApiResponse<dynamic>>> recheckDeliveryOrders({
    required String deliveryRouteId,
    required RecheckDeliveryOrdersBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/m/recheck',
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
  Future<HttpResponse<ApiResponse<dynamic>>> confirmDeliveryOrders({
    required String deliveryRouteId,
    required ConfirmDeliveryOrdersBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/m/confirm',
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
  Future<HttpResponse<ApiResponse<dynamic>>> sortDeliveryOrders({
    required String deliveryRouteId,
    required SortDeliveryOrdersBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/m/sort',
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
  Future<HttpResponse<ApiResponse<dynamic>>> deleteDeliveryOrders({
    required String deliveryRouteId,
    required DeleteDeliveryOrdersBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/m',
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
  Future<HttpResponse<ApiResponse<dynamic>>> confirmSortedDeliveryOrders({
    required String deliveryRouteId,
    required ConfirmSortedDeliveryOrdersBodyRequest body,
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
            '/delivery-route/${deliveryRouteId}/delivery-order/m/confirm-sorted',
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
