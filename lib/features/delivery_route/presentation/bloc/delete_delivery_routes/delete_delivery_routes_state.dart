abstract class DeleteDeliveryRoutesState {
  const DeleteDeliveryRoutesState();
}

class DeleteDeliveryRoutesInitial extends DeleteDeliveryRoutesState {
  const DeleteDeliveryRoutesInitial();
}

class DeleteDeliveryRoutesLoading extends DeleteDeliveryRoutesState {
  const DeleteDeliveryRoutesLoading();
}

class DeleteDeliveryRoutesDone extends DeleteDeliveryRoutesState {
  const DeleteDeliveryRoutesDone();
}

class DeleteDeliveryRoutesFailed extends DeleteDeliveryRoutesState {
  final Object error;

  const DeleteDeliveryRoutesFailed({required this.error});
}
