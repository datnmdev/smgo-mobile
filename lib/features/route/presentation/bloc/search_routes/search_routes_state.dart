abstract class SearchRoutesState {
  final String searchText;

  const SearchRoutesState({this.searchText = ''});
}

class SearchRoutesInitial extends SearchRoutesState {
  const SearchRoutesInitial({super.searchText});
}

class SearchRoutesLoading extends SearchRoutesState {
  const SearchRoutesLoading({super.searchText});
}

class SearchRoutesDone extends SearchRoutesState {
  const SearchRoutesDone({super.searchText});
}

class SearchRoutesError extends SearchRoutesState {
  final Object error;

  const SearchRoutesError({required this.error, super.searchText});
}
