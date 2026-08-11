import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/splash/data/models/app_version_model.dart';

part 'app_version_api_service.g.dart';

@RestApi()
abstract class AppVersionApiService {
  factory AppVersionApiService(Dio dio) = _AppVersionApiService;

  @GET(ApiEndpoints.getLatestAppVersion)
  Future<HttpResponse<ApiResponse<AppVersionModel>>> getLatestAppVersion({
    @Query('platform') required String platform,
  });
}
