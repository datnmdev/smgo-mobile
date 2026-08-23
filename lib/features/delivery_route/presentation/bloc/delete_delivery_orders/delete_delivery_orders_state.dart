abstract class DeleteDeliveryOrdersState {
  const DeleteDeliveryOrdersState();
}

class DeleteDeliveryOrdersInitial extends DeleteDeliveryOrdersState {
  const DeleteDeliveryOrdersInitial();
}

class DeleteDeliveryOrdersLoading extends DeleteDeliveryOrdersState {
  const DeleteDeliveryOrdersLoading();
}

class DeleteDeliveryOrdersDone extends DeleteDeliveryOrdersState {
  const DeleteDeliveryOrdersDone();
}

class DeleteDeliveryOrdersFailed extends DeleteDeliveryOrdersState {
  const DeleteDeliveryOrdersFailed();
}
