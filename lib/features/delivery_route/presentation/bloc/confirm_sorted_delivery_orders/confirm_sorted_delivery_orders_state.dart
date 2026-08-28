abstract class ConfirmSortedDeliveryOrdersState {
  const ConfirmSortedDeliveryOrdersState();
}

class ConfirmSortedDeliveryOrdersInitial extends ConfirmSortedDeliveryOrdersState {
  const ConfirmSortedDeliveryOrdersInitial();
}

class ConfirmSortedDeliveryOrdersLoading extends ConfirmSortedDeliveryOrdersState {
  const ConfirmSortedDeliveryOrdersLoading();
}

class ConfirmSortedDeliveryOrdersDone extends ConfirmSortedDeliveryOrdersState {
  const ConfirmSortedDeliveryOrdersDone();
}

class ConfirmSortedDeliveryOrdersFailed extends ConfirmSortedDeliveryOrdersState {
  final Object error;

  const ConfirmSortedDeliveryOrdersFailed({required this.error});
}
