class ConfirmDeliveredOrderState {
  const ConfirmDeliveredOrderState();
}

class ConfirmDeliveredOrderInitial extends ConfirmDeliveredOrderState {
  const ConfirmDeliveredOrderInitial();
}

class ConfirmDeliveredOrderLoading extends ConfirmDeliveredOrderState {
  const ConfirmDeliveredOrderLoading();
}

class ConfirmDeliveredOrderDone extends ConfirmDeliveredOrderState {
  const ConfirmDeliveredOrderDone();
}

class ConfirmDeliveredOrderFailed extends ConfirmDeliveredOrderState {
  final Object error;

  ConfirmDeliveredOrderFailed({required this.error});
}
