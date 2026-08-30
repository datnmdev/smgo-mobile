class TransitionRouteToCompletedState {
  const TransitionRouteToCompletedState();
}

class TransitionRouteToCompletedInitial
    extends TransitionRouteToCompletedState {
  const TransitionRouteToCompletedInitial();
}

class TransitionRouteToCompletedLoading
    extends TransitionRouteToCompletedState {
  const TransitionRouteToCompletedLoading();
}

class TransitionRouteToCompletedDone extends TransitionRouteToCompletedState {
  const TransitionRouteToCompletedDone();
}

class TransitionRouteToCompletedFailed extends TransitionRouteToCompletedState {
  final Object error;

  TransitionRouteToCompletedFailed({required this.error});
}
