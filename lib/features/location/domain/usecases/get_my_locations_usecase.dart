import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';

class GetMyLocationsUsecase
    implements
        Usecase<DataState<Pagination<LocationEntity>>, GetMyLocationsParams?> {
  final LocationRepository locationRepository;

  const GetMyLocationsUsecase({required this.locationRepository});

  @override
  Future<DataState<Pagination<LocationEntity>>> call({
    GetMyLocationsParams? params,
  }) {
    return locationRepository.getMyLocations(
      params: GetMyLocationParams(
        keyword: params?.keyword,
        pageNumber: params?.pageNumber,
        pageSize: params?.pageSize,
        id: params?.id,
      ),
    );
  }
}

class GetMyLocationsParams {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;

  const GetMyLocationsParams({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
  });
}
