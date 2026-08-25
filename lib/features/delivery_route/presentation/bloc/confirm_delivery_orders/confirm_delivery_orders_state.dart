abstract class ConfirmDeliveryOrdersState {
  const ConfirmDeliveryOrdersState();
}

class ConfirmDeliveryOrdersInitial extends ConfirmDeliveryOrdersState {
  const ConfirmDeliveryOrdersInitial();
}

class ConfirmDeliveryOrdersLoading extends ConfirmDeliveryOrdersState {
  const ConfirmDeliveryOrdersLoading();
}

class ConfirmDeliveryOrdersDone extends ConfirmDeliveryOrdersState {
  const ConfirmDeliveryOrdersDone();
}

class ConfirmDeliveryOrdersFailed extends ConfirmDeliveryOrdersState {
  final Object error;

  const ConfirmDeliveryOrdersFailed({required this.error});
}
