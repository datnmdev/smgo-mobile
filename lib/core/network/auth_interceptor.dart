import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shipgo/app_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/localization/domain/repository/localization_repository.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final LocalizationRepository localizationRepository;
  final TokenRepository tokenRepository;

  AuthInterceptor({
    required this.dio,
    required this.localizationRepository,
    required this.tokenRepository,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenRepository.getAccessToken();
    final localeTag = await localizationRepository.getLocaleTag();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    options.queryParameters.addAll({"locale": localeTag});
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      try {
        final newAccessToken = await _refreshToken();
        if (newAccessToken != null) {
          await tokenRepository.saveAccessToken(newAccessToken);
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        await _logout();
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await tokenRepository.getRefreshToken();
    if (refreshToken == null) return null;
    final tokenDio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
    final response = await tokenDio.post(
      '/${ApiEndpoints.authBaseUrl}/${ApiEndpoints.refreshToken}',
      data: {'refreshToken': refreshToken},
    );
    if (response.statusCode == 200) {
      return response.data['accessToken'];
    }
    return null;
  }

  Future<void> _logout() async {
    await tokenRepository.clearToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.goNamed(AppRouteNames.signIn);
    });
  }
}
