abstract class ConfirmDeliveryOrderState {
  const ConfirmDeliveryOrderState();
}

class ConfirmDeliveryOrderInitial extends ConfirmDeliveryOrderState {
  const ConfirmDeliveryOrderInitial();
}

class ConfirmDeliveryOrderLoading extends ConfirmDeliveryOrderState {
  const ConfirmDeliveryOrderLoading();
}

class ConfirmDeliveryOrderDone extends ConfirmDeliveryOrderState {
  const ConfirmDeliveryOrderDone();
}

class ConfirmDeliveryOrderFailed extends ConfirmDeliveryOrderState {
  final Object error;

  const ConfirmDeliveryOrderFailed({required this.error});
}
