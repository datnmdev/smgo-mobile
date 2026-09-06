import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smgo/core/network/api_enpoints.dart';
import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/shared/data/models/user_model.dart';

part 'user_api_service.g.dart';

@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio) = _UserApiService;

  @GET(ApiEndpoints.getProfile)
  Future<HttpResponse<ApiResponse<UserModel>>> getProfile();

  @POST(ApiEndpoints.updateProfile)
  Future<HttpResponse<ApiResponse<dynamic>>> updateProfile({
    @Body() required UpdateProfileBodyRequest body,
  });
}

@JsonSerializable(includeIfNull: false)
class UpdateProfileBodyRequest {
  final String? name;
  final String? avatar;

  UpdateProfileBodyRequest({this.name, this.avatar});

  Map<String, dynamic> toJson() => _$UpdateProfileBodyRequestToJson(this);
}
