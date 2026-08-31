abstract class SearchLocationsState {
  final String searchText;

  const SearchLocationsState({this.searchText = ''});
}

class SearchLocationsInitial extends SearchLocationsState {
  const SearchLocationsInitial({super.searchText});
}

class SearchLocationsLoading extends SearchLocationsState {
  const SearchLocationsLoading({super.searchText});
}

class SearchLocationsDone extends SearchLocationsState {
  const SearchLocationsDone({super.searchText});
}

class SearchLocationsError extends SearchLocationsState {
  final Object error;

  const SearchLocationsError({required this.error, super.searchText});
}
