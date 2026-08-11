import 'package:dio/dio.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/localization/domain/repository/localization_repository.dart';
import 'auth_interceptor.dart';

Dio createDio({required LocalizationRepository localizationRepository}) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(dio: dio, localizationRepository: localizationRepository),
  );
  return dio;
}
