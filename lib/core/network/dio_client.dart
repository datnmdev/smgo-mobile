import 'package:dio/dio.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/security/token/domain/repository/token_repository.dart';
import 'auth_interceptor.dart';

Dio createDio({
  required LocalizationRepository localizationRepository,
  required TokenRepository tokenRepository,
}) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      localizationRepository: localizationRepository,
      tokenRepository: tokenRepository,
    ),
  );
  return dio;
}
