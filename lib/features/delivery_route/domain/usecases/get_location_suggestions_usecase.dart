import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/location_search_repository.dart';
import 'package:smgo/shared/domain/entities/location_entity.dart';

class GetLocationSuggestionsUsecase
    implements
        Usecase<
          DataState<Pagination<LocationEntity>>,
          GetLocationSuggestionsUsecaseParams
        > {
  final LocationSearchRepository locationSearchRepository;

  GetLocationSuggestionsUsecase({required this.locationSearchRepository});
  @override
  Future<DataState<Pagination<LocationEntity>>> call({
    required GetLocationSuggestionsUsecaseParams params,
  }) {
    return locationSearchRepository.getLocationSuggestions(
      params: GetLocationSuggestionsParams(
        contactPhone: params.contactPhone,
        address: params.address,
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
      ),
    );
  }
}

class GetLocationSuggestionsUsecaseParams {
  final String? contactPhone;
  final String? address;
  final int pageNumber;
  final int pageSize;

  GetLocationSuggestionsUsecaseParams({
    this.contactPhone,
    this.address,
    required this.pageNumber,
    required this.pageSize,
  });
}
