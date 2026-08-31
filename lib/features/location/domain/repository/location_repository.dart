import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<DataState<Pagination<LocationEntity>>> getMyLocations({
    GetMyLocationParams? params,
  });
  Future<DataState<dynamic>> createLocation({
    required CreateLocationParams params,
  });
  Future<DataState<dynamic>> updateLocation({
    required String locationId,
    required UpdateLocationData data,
  });
  Future<DataState<dynamic>> deleteLocations({required List<String> locationIds});
}

class GetMyLocationParams {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;

  const GetMyLocationParams({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
  });
}

class LocationData {
  final double x;
  final double y;

  const LocationData({required this.x, required this.y});
}

class CreateLocationParams {
  String locationName;
  String contactName;
  String contactPhone;
  String address;
  List<String>? mediaIds;
  String? note;
  LocationData? location;

  CreateLocationParams({
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    this.mediaIds,
    this.note,
    this.location,
  });
}

class UpdateLocationData {
  String? locationName;
  String? contactName;
  String? contactPhone;
  String? address;
  List<String>? mediaIds;
  String? note;
  LocationData? location;

  UpdateLocationData({
    this.locationName,
    this.contactName,
    this.contactPhone,
    this.address,
    this.mediaIds,
    this.note,
    this.location,
  });
}
