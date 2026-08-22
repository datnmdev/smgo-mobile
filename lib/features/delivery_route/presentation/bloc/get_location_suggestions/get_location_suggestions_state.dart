import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';

abstract class GetLocationSuggestionsState {
  const GetLocationSuggestionsState();
}

class GetLocationSuggestionsInitial extends GetLocationSuggestionsState {
  const GetLocationSuggestionsInitial();
}

class GetLocationSuggestionsLoading extends GetLocationSuggestionsState {
  const GetLocationSuggestionsLoading();
}

class GetLocationSuggestionsDone extends GetLocationSuggestionsState {
  final Pagination<LocationEntity> locationSuggestions;

  const GetLocationSuggestionsDone({required this.locationSuggestions});
}

class GetLocationSuggestionsError extends GetLocationSuggestionsState {
  final Object error;

  const GetLocationSuggestionsError({required this.error});
}
