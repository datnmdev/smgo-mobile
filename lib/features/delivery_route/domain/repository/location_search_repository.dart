import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';

abstract class LocationSearchRepository {
  Future<DataState<Pagination<LocationEntity>>> getLocationSuggestions({
    required GetLocationSuggestionsParams params,
  });
}

class GetLocationSuggestionsParams {
  final String contactName;
  final String contactPhone;
  final String address;
  final int pageNumber;
  final int pageSize;

  GetLocationSuggestionsParams({
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.pageNumber,
    required this.pageSize
  });
}
