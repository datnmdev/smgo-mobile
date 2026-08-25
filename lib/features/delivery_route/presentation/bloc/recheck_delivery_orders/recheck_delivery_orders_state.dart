abstract class RecheckDeliveryOrdersState {
  const RecheckDeliveryOrdersState();
}

class RecheckDeliveryOrdersInitial extends RecheckDeliveryOrdersState {
  const RecheckDeliveryOrdersInitial();
}

class RecheckDeliveryOrdersLoading extends RecheckDeliveryOrdersState {
  const RecheckDeliveryOrdersLoading();
}

class RecheckDeliveryOrdersDone extends RecheckDeliveryOrdersState {
  const RecheckDeliveryOrdersDone();
}

class RecheckDeliveryOrdersFailed extends RecheckDeliveryOrdersState {
  final Object error;

  const RecheckDeliveryOrdersFailed({required this.error});
}
