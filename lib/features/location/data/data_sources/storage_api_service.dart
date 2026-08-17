import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/location/data/models/upload_url_model.dart';

part 'storage_api_service.g.dart';

@RestApi()
abstract class StorageApiService {
  factory StorageApiService(Dio dio) = _StorageApiService;

  @GET(ApiEndpoints.getUploadUrl)
  Future<HttpResponse<ApiResponse<UploadUrlModel>>> getUploadUrl();

  @GET(ApiEndpoints.getDownloadUrl)
  Future<HttpResponse<ApiResponse<String>>> getDownloadUrl({
    @Query('fileKey') required String fileKey,
  });
}
