import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';

part 'share_location_api_service.g.dart';

@RestApi()
abstract class ShareLocationApiService {
  factory ShareLocationApiService(Dio dio) = _ShareLocationApiService;

  @GET(ApiEndpoints.getShareLocationUrl)
  Future<HttpResponse<ApiResponse<String>>> getShareLocationUrl({
    @Queries() required GetShareLocationUrlQueryRequest query,
  });
}

@JsonSerializable()
class GetShareLocationUrlQueryRequest {
  final String deliveryRouteId;
  final String deliveryOrderId;

  GetShareLocationUrlQueryRequest({
    required this.deliveryRouteId,
    required this.deliveryOrderId,
  });

  Map<String, dynamic> toJson() =>
      _$GetShareLocationUrlQueryRequestToJson(this);
}
