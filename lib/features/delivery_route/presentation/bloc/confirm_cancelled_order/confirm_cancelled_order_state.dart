class ConfirmCancelledOrderState {
  const ConfirmCancelledOrderState();
}

class ConfirmCancelledOrderInitial extends ConfirmCancelledOrderState {
  const ConfirmCancelledOrderInitial();
}

class ConfirmCancelledOrderLoading extends ConfirmCancelledOrderState {
  const ConfirmCancelledOrderLoading();
}

class ConfirmCancelledOrderDone extends ConfirmCancelledOrderState {
  const ConfirmCancelledOrderDone();
}

class ConfirmCancelledOrderFailed extends ConfirmCancelledOrderState {
  final Object error;

  ConfirmCancelledOrderFailed({required this.error});
}
