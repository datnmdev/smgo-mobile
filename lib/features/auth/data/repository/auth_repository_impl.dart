import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/auth/data/data_sources/auth_api_service.dart';
import 'package:shipgo/features/auth/data/exceptions/unauthenticated_exception.dart';
import 'package:shipgo/features/auth/data/exceptions/user_canceled_exception.dart';
import 'package:shipgo/features/auth/data/models/auth_token_model.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  const AuthRepositoryImpl(this._authApiService);

  @override
  Future<DataState<AuthTokensModel>> signInWithGoogle() async {
    try {
      // Xác thực phía google
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      // Xác thực phía backend
      final httpResponse = await _authApiService.signInWithGoogle(
        body: SignInWithGoogleBodyRequest(
          idToken: googleUser.authentication.idToken!,
        ),
      );
      if (httpResponse.response.statusCode == HttpStatus.created) {
        AuthTokensModel authTokensModel = httpResponse.data.data!;
        return DataSuccess(authTokensModel);
      } else {
        return DataFailed(UserCanceledException());
      }
    } on DioException catch (error) {
      return DataFailed(error);
    } on GoogleSignInException {
      return DataFailed(UserCanceledException());
    } catch (e) {
      return DataFailed(UnauthenticatedException());
    }
  }

  @override
  Future<DataState<AuthTokensModel>> signInWithFacebook() async {
    try {
      // Xác thực phía facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );
      if (result.status == LoginStatus.success) {
        // Xác thực phía backend
        final httpResponse = await _authApiService.signInWithFacebook(
          body: SignInWithFacebookBodyRequest(
            inputToken: result.accessToken!.token,
          ),
        );
        if (httpResponse.response.statusCode == HttpStatus.created) {
          AuthTokensModel authTokensModel = httpResponse.data.data!;
          return DataSuccess(authTokensModel);
        } else {
          return DataFailed(UserCanceledException());
        }
      } else if (result.status == LoginStatus.cancelled) {
        return DataFailed(UserCanceledException());
      } else {
        return DataFailed(UnauthenticatedException());
      }
    } on DioException catch (error) {
      return DataFailed(error);
    } catch (e) {
      return DataFailed(UnauthenticatedException());
    }
  }
}
