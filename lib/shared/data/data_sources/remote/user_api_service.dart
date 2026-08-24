import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/shared/data/models/user_model.dart';

part 'user_api_service.g.dart';

@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio) = _UserApiService;

  @GET(ApiEndpoints.getProfile)
  Future<HttpResponse<ApiResponse<UserModel>>> getProfile();
}
