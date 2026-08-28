import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';

part 'ai_api_service.g.dart';

@RestApi()
abstract class AiApiService {
  factory AiApiService(Dio dio) = _AiApiService;

  @GET(ApiEndpoints.extractOrderInfo)
  Future<HttpResponse<ApiResponse<String>>> extractOrderInfo({
    @Query('ocrText') required String ocrText,
  });
}
