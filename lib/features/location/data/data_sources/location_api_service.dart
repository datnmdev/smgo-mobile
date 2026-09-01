import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/shared/data/models/location_model.dart';

part 'location_api_service.g.dart';

@RestApi()
abstract class LocationApiService {
  factory LocationApiService(Dio dio) = _LocationApiService;

  @GET(ApiEndpoints.getMyLocations)
  Future<HttpResponse<ApiResponse<Pagination<LocationModel>>>> getMyLocations({
    @Queries() required GetMyLocationsQuery query,
  });

  @POST(ApiEndpoints.createLocation)
  Future<HttpResponse<ApiResponse<dynamic>>> createLocation({
    @Body() required CreateLocationBodyRequest body,
  });

  @PUT(ApiEndpoints.updateLocation)
  Future<HttpResponse<ApiResponse<dynamic>>> updateLocation({
    @Path('locationId') required String locationId,
    @Body() required UpdateLocationBodyRequest body,
  });

  @DELETE(ApiEndpoints.deleteLocations)
  Future<HttpResponse<ApiResponse<dynamic>>> deleteLocations({
    @Body() required DeleteLocationsBodyRequest body,
  });
}

@JsonSerializable(includeIfNull: false)
class GetMyLocationsQuery {
  final String? keyword;
  final int? page;
  final int? limit;
  final String? id;

  const GetMyLocationsQuery({this.keyword, this.page, this.limit, this.id});

  Map<String, dynamic> toJson() => _$GetMyLocationsQueryToJson(this);
}

@JsonSerializable()
class LocationBodyRequest {
  final double x;
  final double y;

  const LocationBodyRequest({required this.x, required this.y});

  factory LocationBodyRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationBodyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationBodyRequestToJson(this);
}

@JsonSerializable()
class CreateLocationBodyRequest {
  String locationName;
  String contactName;
  String contactPhone;
  String address;
  List<String>? mediaIds;
  String? note;
  LocationBodyRequest? location;

  CreateLocationBodyRequest({
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    this.mediaIds,
    this.note,
    this.location,
  });

  Map<String, dynamic> toJson() => _$CreateLocationBodyRequestToJson(this);
}

@JsonSerializable()
class UpdateLocationBodyRequest {
  String? locationName;
  String? contactName;
  String? contactPhone;
  String? address;
  List<String>? mediaIds;
  String? note;
  LocationBodyRequest? location;

  UpdateLocationBodyRequest({
    this.locationName,
    this.contactName,
    this.contactPhone,
    this.address,
    this.mediaIds,
    this.note,
    this.location,
  });

  Map<String, dynamic> toJson() => _$UpdateLocationBodyRequestToJson(this);
}

@JsonSerializable()
class DeleteLocationsBodyRequest {
  final List<String> locationIds;

  DeleteLocationsBodyRequest({required this.locationIds});

  Map<String, dynamic> toJson() => _$DeleteLocationsBodyRequestToJson(this);
}
