import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/shared/data/models/subscription_model.dart';

part 'subscription_api_service.g.dart';

@RestApi()
abstract class SubscriptionApiService {
  factory SubscriptionApiService(Dio dio) = _SubscriptionApiService;

  @GET(ApiEndpoints.getCurrentSubscription)
  Future<HttpResponse<ApiResponse<SubscriptionModel>>> getCurrentSubscription();

  @POST(ApiEndpoints.verify)
  Future<HttpResponse<ApiResponse<bool>>> verify({
    @Body() required VerifySubscriptionBodyRequest body,
  });
}

@JsonSerializable()
class VerifySubscriptionBodyRequest {
  final String platform;
  final String purchaseToken;

  VerifySubscriptionBodyRequest({
    required this.platform,
    required this.purchaseToken,
  });

  Map<String, dynamic> toJson() => _$VerifySubscriptionBodyRequestToJson(this);
}
