class DeleteLocationState {
  const DeleteLocationState();
}

class DeleteLocationInitial extends DeleteLocationState {
  const DeleteLocationInitial();
}

class DeleteLocationLoading extends DeleteLocationState {
  const DeleteLocationLoading();
}

class DeleteLocationDone extends DeleteLocationState {
  const DeleteLocationDone();
}

class DeleteLocationFailed extends DeleteLocationState {
  final Object error;

  const DeleteLocationFailed({required this.error});
}
