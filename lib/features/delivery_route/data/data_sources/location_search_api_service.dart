import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/shared/data/models/location_model.dart';

part 'location_search_api_service.g.dart';

@RestApi()
abstract class LocationSearchApiService {
  factory LocationSearchApiService(Dio dio) = _LocationSearchApiService;

  @GET(ApiEndpoints.getLocationSuggestions)
  Future<HttpResponse<ApiResponse<Pagination<LocationModel>>>>
  getLocationSuggestions({
    @Queries() required GetLocationSuggestionsQuery query,
  });
}

@JsonSerializable(includeIfNull: false)
class GetLocationSuggestionsQuery {
  final int pageNumber;
  final int pageSize;
  final String? contactPhone;
  final String? address;

  const GetLocationSuggestionsQuery({
    required this.pageNumber,
    required this.pageSize,
    this.contactPhone,
    this.address,
  });

  Map<String, dynamic> toJson() => _$GetLocationSuggestionsQueryToJson(this);
}
