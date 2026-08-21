import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/data/data_sources/location_api_service.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/shared/domain/entities/media_entity.dart';
import 'package:shipgo/shared/domain/entities/point_entity.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationApiService locationApiService;

  const LocationRepositoryImpl({required this.locationApiService});

  @override
  Future<DataState<Pagination<LocationEntity>>> getMyLocations({
    GetMyLocationParams? params,
  }) async {
    try {
      final dataState = await locationApiService.getMyLocations(
        query: GetMyLocationsQuery(
          page: params?.pageNumber,
          limit: params?.pageSize,
          keyword: params?.keyword,
          id: params?.id,
        ),
      );
      final data = dataState.data.data!;
      return DataSuccess(
        Pagination(
          meta: data.meta,
          data: data.data
              .map(
                (locationModel) => LocationEntity(
                  id: locationModel.id,
                  locationName: locationModel.locationName,
                  contactName: locationModel.contactName,
                  contactPhone: locationModel.contactPhone,
                  media: locationModel.media
                      .map((media) => MediaEntity(id: media.id, url: media.url))
                      .toList(),
                  note: locationModel.note,
                  address: locationModel.address,
                  location: PointEntity(
                    x: locationModel.location.x,
                    y: locationModel.location.y,
                  ),
                  createdAt: locationModel.createdAt,
                  updatedAt: locationModel.updatedAt,
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> createLocation({
    required CreateLocationParams params,
  }) async {
    try {
      final dataState = await locationApiService.createLocation(
        body: CreateLocationBodyRequest(
          locationName: params.locationName,
          contactName: params.contactName,
          contactPhone: params.contactPhone,
          address: params.address,
          location: params.location != null
              ? LocationBodyRequest(
                  x: params.location!.x,
                  y: params.location!.y,
                )
              : null,
          note: params.note,
          mediaIds: params.mediaIds,
        ),
      );
      return DataSuccess(dataState.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> updateLocation({
    required String locationId,
    required UpdateLocationData data,
  }) async {
    try {
      final dataState = await locationApiService.updateLocation(
        locationId: locationId,
        body: UpdateLocationBodyRequest(
          locationName: data.locationName,
          contactName: data.contactName,
          contactPhone: data.contactPhone,
          address: data.address,
          location: data.location != null
              ? LocationBodyRequest(x: data.location!.x, y: data.location!.y)
              : null,
          note: data.note,
          mediaIds: data.mediaIds,
        ),
      );
      return DataSuccess(dataState.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> deleteLocation({
    required String locationId,
  }) async {
    try {
      final dataState = await locationApiService.deleteLocation(
        locationId: locationId,
      );
      return DataSuccess(dataState.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
