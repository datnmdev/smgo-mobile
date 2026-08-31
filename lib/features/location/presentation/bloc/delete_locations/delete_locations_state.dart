class DeleteLocationsState {
  const DeleteLocationsState();
}

class DeleteLocationsInitial extends DeleteLocationsState {
  const DeleteLocationsInitial();
}

class DeleteLocationsLoading extends DeleteLocationsState {
  const DeleteLocationsLoading();
}

class DeleteLocationsDone extends DeleteLocationsState {
  const DeleteLocationsDone();
}

class DeleteLocationsFailed extends DeleteLocationsState {
  final Object error;

  const DeleteLocationsFailed({required this.error});
}
