abstract class SortDeliveryOrdersState {
  const SortDeliveryOrdersState();
}

class SortDeliveryOrdersInitial extends SortDeliveryOrdersState {
  const SortDeliveryOrdersInitial();
}

class SortDeliveryOrdersLoading extends SortDeliveryOrdersState {
  const SortDeliveryOrdersLoading();
}

class SortDeliveryOrdersDone extends SortDeliveryOrdersState {
  const SortDeliveryOrdersDone();
}

class SortDeliveryOrdersFailed extends SortDeliveryOrdersState {
  final Object error;

  const SortDeliveryOrdersFailed({required this.error});
}
