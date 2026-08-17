import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/location/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';

class GetMyLocationsUsecase
    implements
        Usecase<
          DataState<Pagination<List<LocationEntity>>>,
          GetMyLocationsParams?
        > {
  final LocationRepository locationRepository;

  const GetMyLocationsUsecase({required this.locationRepository});

  @override
  Future<DataState<Pagination<List<LocationEntity>>>> call({
    GetMyLocationsParams? params,
  }) {
    return locationRepository.getMyLocations(
      query: GetMyLocationQuery(
        keyword: params?.keyword,
        pageNumber: params?.pageNumber,
        pageSize: params?.pageSize,
      ),
    );
  }
}

class GetMyLocationsParams {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;

  const GetMyLocationsParams({this.keyword, this.pageNumber, this.pageSize});
}
