import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';

part 'session_api_service.g.dart';

@RestApi()
abstract class SessionApiService {
  factory SessionApiService(Dio dio) = _SessionApiService;

  @POST(ApiEndpoints.signout)
  Future<HttpResponse<ApiResponse<dynamic>>> signout();
}