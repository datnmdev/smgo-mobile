class TransitionRouteToSortingState {
  const TransitionRouteToSortingState();
}

class TransitionRouteToSortingInitial extends TransitionRouteToSortingState {
  const TransitionRouteToSortingInitial();
}

class TransitionRouteToSortingLoading extends TransitionRouteToSortingState {
  const TransitionRouteToSortingLoading();
}

class TransitionRouteToSortingDone extends TransitionRouteToSortingState {
  const TransitionRouteToSortingDone();
}

class TransitionRouteToSortingFailed extends TransitionRouteToSortingState {
  final Object error;

  TransitionRouteToSortingFailed({required this.error});
}
