abstract class SearchDeliveryRoutesState {
  final String searchText;

  const SearchDeliveryRoutesState({this.searchText = ''});
}

class SearchDeliveryRoutesInitial extends SearchDeliveryRoutesState {
  const SearchDeliveryRoutesInitial({super.searchText});
}

class SearchDeliveryRoutesLoading extends SearchDeliveryRoutesState {
  const SearchDeliveryRoutesLoading({super.searchText});
}

class SearchDeliveryRoutesDone extends SearchDeliveryRoutesState {
  const SearchDeliveryRoutesDone({super.searchText});
}

class SearchDeliveryRoutesError extends SearchDeliveryRoutesState {
  final Object error;

  const SearchDeliveryRoutesError({required this.error, super.searchText});
}
