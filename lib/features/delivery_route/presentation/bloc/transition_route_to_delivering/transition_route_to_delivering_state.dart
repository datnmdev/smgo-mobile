class TransitionRouteToDeliveringState {
  const TransitionRouteToDeliveringState();
}

class TransitionRouteToDeliveringInitial extends TransitionRouteToDeliveringState {
  const TransitionRouteToDeliveringInitial();
}

class TransitionRouteToDeliveringLoading extends TransitionRouteToDeliveringState {
  const TransitionRouteToDeliveringLoading();
}

class TransitionRouteToDeliveringDone extends TransitionRouteToDeliveringState {
  const TransitionRouteToDeliveringDone();
}

class TransitionRouteToDeliveringFailed extends TransitionRouteToDeliveringState {
  final Object error;

  TransitionRouteToDeliveringFailed({required this.error});
}
