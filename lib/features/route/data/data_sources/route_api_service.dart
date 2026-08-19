import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/route/data/models/route_model.dart';

part 'route_api_service.g.dart';

@RestApi()
abstract class RouteApiService {
  factory RouteApiService(Dio dio) = _RouteApiService;

  @GET(ApiEndpoints.getMyRoutes)
  Future<HttpResponse<ApiResponse<Pagination<RouteModel>>>> getMyRoutes({
    @Queries() required GetMyRoutesQueryRequest queries,
  });

  @POST(ApiEndpoints.addRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> addRoute({
    @Body() required AddRouteBodyRequest body,
  });

  @PUT(ApiEndpoints.updateMyRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> updateMyRoute({
    @Path('routeId') required String id,
    @Body() required UpdateMyRouteBodyRequest body,
  });

  @DELETE(ApiEndpoints.deleteMyRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> deleteMyRoute({
    @Path('routeId') required String id,
  });
}

@JsonSerializable(includeIfNull: false)
class GetMyRoutesQueryRequest {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;
  final String? status;

  GetMyRoutesQueryRequest({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
    this.status,
  });

  Map<String, dynamic> toJson() => _$GetMyRoutesQueryRequestToJson(this);
}

@JsonSerializable()
class AddRouteBodyRequest {
  final String name;

  AddRouteBodyRequest({required this.name});

  Map<String, dynamic> toJson() => _$AddRouteBodyRequestToJson(this);
}

@JsonSerializable()
class UpdateMyRouteBodyRequest {
  final String? name;

  UpdateMyRouteBodyRequest({this.name});

  Map<String, dynamic> toJson() => _$UpdateMyRouteBodyRequestToJson(this);
}
