import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/data/data_sources/location_search_api_service.dart';
import 'package:shipgo/features/delivery_route/domain/repository/location_search_repository.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/shared/domain/entities/media_entity.dart';
import 'package:shipgo/shared/domain/entities/point_entity.dart';

class LocationSearchRepositoryImpl implements LocationSearchRepository {
  final LocationSearchApiService locationSearchApiService;

  LocationSearchRepositoryImpl({required this.locationSearchApiService});

  @override
  Future<DataState<Pagination<LocationEntity>>> getLocationSuggestions({
    required GetLocationSuggestionsParams params,
  }) async {
    try {
      final dataState = await locationSearchApiService.getLocationSuggestions(
        query: GetLocationSuggestionsQuery(
          pageNumber: params.pageNumber,
          pageSize: params.pageSize,
          contactPhone: params.contactPhone,
          address: params.address,
        ),
      );
      return DataSuccess(
        Pagination(
          meta: dataState.data.data!.meta,
          data: dataState.data.data!.data
              .map(
                (locationModel) => LocationEntity(
                  id: locationModel.id,
                  locationName: locationModel.locationName,
                  contactName: locationModel.contactName,
                  contactPhone: locationModel.contactPhone,
                  media: locationModel.media
                      .map((e) => MediaEntity(id: e.id, url: e.url))
                      .toList(),
                  address: locationModel.address,
                  location: PointEntity(
                    x: locationModel.location.x,
                    y: locationModel.location.y,
                  ),
                  note: locationModel.note,
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
}
