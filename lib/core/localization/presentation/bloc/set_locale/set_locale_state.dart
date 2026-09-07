abstract class SetLocaleState {
  const SetLocaleState();
}

class SetLocaleInitial extends SetLocaleState {
  const SetLocaleInitial();
}

class SetLocaleLoading extends SetLocaleState {
  const SetLocaleLoading();
}

class SetLocaleDone extends SetLocaleState {
  const SetLocaleDone();
}

class SetLocaleFailed extends SetLocaleState {
  final Object error;

  const SetLocaleFailed({required this.error});
}
