class ConfirmRescheduledOrderState {
  const ConfirmRescheduledOrderState();
}

class ConfirmRescheduledOrderInitial extends ConfirmRescheduledOrderState {
  const ConfirmRescheduledOrderInitial();
}

class ConfirmRescheduledOrderLoading extends ConfirmRescheduledOrderState {
  const ConfirmRescheduledOrderLoading();
}

class ConfirmRescheduledOrderDone extends ConfirmRescheduledOrderState {
  const ConfirmRescheduledOrderDone();
}

class ConfirmRescheduledOrderFailed extends ConfirmRescheduledOrderState {
  final Object error;

  ConfirmRescheduledOrderFailed({required this.error});
}
