import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<DataState<Pagination<LocationEntity>>> getMyLocations({
    GetMyLocationQuery? query,
  });
  Future<DataState<LocationEntity>> saveLocation({
    required SaveLocationData data,
  });
  Future<DataState<void>> updateLocation({
    required String locationId,
    required UpdateLocationData data,
  });
  Future<DataState<dynamic>> deleteLocation({required String locationId});
}

class GetMyLocationQuery {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;

  const GetMyLocationQuery({
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

class SaveLocationData {
  String locationName;
  String contactName;
  String contactPhone;
  String address;
  List<String>? mediaIds;
  String? note;
  LocationData? location;

  SaveLocationData({
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
