// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInWithFacebookBodyRequest _$SignInWithFacebookBodyRequestFromJson(
  Map<String, dynamic> json,
) => SignInWithFacebookBodyRequest(inputToken: json['inputToken'] as String);

Map<String, dynamic> _$SignInWithFacebookBodyRequestToJson(
  SignInWithFacebookBodyRequest instance,
) => <String, dynamic>{'inputToken': instance.inputToken};

SignInWithGoogleBodyRequest _$SignInWithGoogleBodyRequestFromJson(
  Map<String, dynamic> json,
) => SignInWithGoogleBodyRequest(idToken: json['idToken'] as String);

Map<String, dynamic> _$SignInWithGoogleBodyRequestToJson(
  SignInWithGoogleBodyRequest instance,
) => <String, dynamic>{'idToken': instance.idToken};

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _AuthApiService implements AuthApiService {
  _AuthApiService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<ApiResponse<AuthTokensModel>>> signInWithGoogle({
    required SignInWithGoogleBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<HttpResponse<ApiResponse<AuthTokensModel>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/auth/google',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<AuthTokensModel> _value;
    try {
      _value = ApiResponse<AuthTokensModel>.fromJson(
        _result.data!,
        (json) => AuthTokensModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ApiResponse<AuthTokensModel>>> signInWithFacebook({
    required SignInWithFacebookBodyRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<HttpResponse<ApiResponse<AuthTokensModel>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/auth/facebook',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<AuthTokensModel> _value;
    try {
      _value = ApiResponse<AuthTokensModel>.fromJson(
        _result.data!,
        (json) => AuthTokensModel.fromJson(json as Map<String, dynamic>),
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
