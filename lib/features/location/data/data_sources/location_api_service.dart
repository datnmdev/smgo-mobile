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

  @POST(ApiEndpoints.locationBaseUrl)
  Future<HttpResponse<ApiResponse<LocationModel>>> saveLocation({
    @Body() required SaveLocationBodyRequest body,
  });

  @PUT(ApiEndpoints.updateLocation)
  Future<HttpResponse<ApiResponse<dynamic>>> updateLocation({
    @Path('locationId') required String locationId,
    @Body() required UpdateLocationBodyRequest body,
  });

  @DELETE(ApiEndpoints.deleteLocation)
  Future<HttpResponse<ApiResponse<dynamic>>> deleteLocation({
    @Path('locationId') required String locationId,
  });
}

@JsonSerializable()
class LocationDataRequest {
  final double x;
  final double y;

  const LocationDataRequest({required this.x, required this.y});

  factory LocationDataRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationDataRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataRequestToJson(this);
}

@JsonSerializable()
class SaveLocationBodyRequest {
  String locationName;
  String contactName;
  String contactPhone;
  String address;
  List<String>? mediaIds;
  String? note;
  LocationDataRequest? location;

  SaveLocationBodyRequest({
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    this.mediaIds,
    this.note,
    this.location,
  });

  Map<String, dynamic> toJson() => _$SaveLocationBodyRequestToJson(this);
}

@JsonSerializable()
class UpdateLocationBodyRequest {
  String? locationName;
  String? contactName;
  String? contactPhone;
  String? address;
  List<String>? mediaIds;
  String? note;
  LocationDataRequest? location;

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
