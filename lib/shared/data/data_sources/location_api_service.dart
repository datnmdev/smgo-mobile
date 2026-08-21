import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/location/data/models/location_model.dart';

part 'location_api_service.g.dart';

@RestApi()
abstract class LocationApiService {
  factory LocationApiService(Dio dio) = _LocationApiService;

  @GET(ApiEndpoints.locationBaseUrl)
  Future<HttpResponse<ApiResponse<Pagination<LocationModel>>>> getLocations({
    @Queries() required GetLocationsQuery query,
  });
}

@JsonSerializable(includeIfNull: false)
class GetLocationsQuery {
  final String? keyword;
  final int? page;
  final int? limit;
  final String? id;

  const GetLocationsQuery({this.keyword, this.page, this.limit, this.id});

  Map<String, dynamic> toJson() => _$GetLocationsQueryToJson(this);
}
