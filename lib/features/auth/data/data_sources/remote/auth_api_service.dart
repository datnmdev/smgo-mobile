import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/auth/data/models/request/sign_in_with_google_request.dart';
import 'package:shipgo/features/auth/data/models/response/auth_token_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthAPIService {
  factory AuthAPIService(Dio dio) = _AuthAPIService;

  @POST(ApiEndpoints.signInWithGoogle)
  Future<HttpResponse<ApiResponse<AuthTokensModel>>> signInWithGoogle({
    @Body() required SignInWithGoogleBodyRequest body,
  });
}
