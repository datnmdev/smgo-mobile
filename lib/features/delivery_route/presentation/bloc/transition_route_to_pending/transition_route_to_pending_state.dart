class TransitionRouteToPendingState {
  const TransitionRouteToPendingState();
}

class TransitionRouteToPendingInitial extends TransitionRouteToPendingState {
  const TransitionRouteToPendingInitial();
}

class TransitionRouteToPendingLoading extends TransitionRouteToPendingState {
  const TransitionRouteToPendingLoading();
}

class TransitionRouteToPendingDone extends TransitionRouteToPendingState {
  const TransitionRouteToPendingDone();
}

class TransitionRouteToPendingFailed extends TransitionRouteToPendingState {
  final Object error;

  TransitionRouteToPendingFailed({required this.error});
}
