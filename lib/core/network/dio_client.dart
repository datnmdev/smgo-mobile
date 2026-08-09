import 'package:dio/dio.dart';
import 'package:shipgo/core/config/env.dart';
import 'auth_interceptor.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(AuthInterceptor(dio));
  return dio;
}
