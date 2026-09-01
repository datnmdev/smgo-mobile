import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/features/auth/data/models/auth_token_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST(ApiEndpoints.signInWithGoogle)
  Future<HttpResponse<ApiResponse<AuthTokensModel>>> signInWithGoogle({
    @Body() required SignInWithGoogleBodyRequest body,
  });

  @POST(ApiEndpoints.signInWithFacebook)
  Future<HttpResponse<ApiResponse<AuthTokensModel>>> signInWithFacebook({
    @Body() required SignInWithFacebookBodyRequest body,
  });
}

@JsonSerializable()
class SignInWithFacebookBodyRequest {
  final String inputToken;
  const SignInWithFacebookBodyRequest({required this.inputToken});
  Map<String, dynamic> toJson() => _$SignInWithFacebookBodyRequestToJson(this);
}

@JsonSerializable()
class SignInWithGoogleBodyRequest {
  final String idToken;
  const SignInWithGoogleBodyRequest({required this.idToken});
  Map<String, dynamic> toJson() => _$SignInWithGoogleBodyRequestToJson(this);
}