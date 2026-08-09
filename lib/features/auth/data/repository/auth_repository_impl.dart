import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shipgo/core/config/env.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/auth/data/data_sources/remote/auth_api_service.dart';
import 'package:shipgo/features/auth/data/exceptions/unauthenticated_exception.dart';
import 'package:shipgo/features/auth/data/exceptions/user_canceled_exception.dart';
import 'package:shipgo/features/auth/data/models/request/sign_in_with_google_request.dart';
import 'package:shipgo/features/auth/data/models/response/auth_token_model.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthAPIService _authAPIService;

  const AuthRepositoryImpl(this._authAPIService);

  @override
  Future<DataState<AuthTokensModel>> signInWithGoogle() async {
    try {
      // Xác thực phía google
      await GoogleSignIn.instance.initialize(
        serverClientId: Env.googleWebClientId,
      );
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      // Xác thực phía backend
      final httpResponse = await _authAPIService.signInWithGoogle(
        body: SignInWithGoogleBodyRequest(
          idToken: googleUser.authentication.idToken!,
        ),
      );
      if (httpResponse.response.statusCode == HttpStatus.created) {
        return DataSuccess(httpResponse.data.data!);
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
}
