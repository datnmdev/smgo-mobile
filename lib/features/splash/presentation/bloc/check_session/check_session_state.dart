abstract class CheckSessionState {
  const CheckSessionState();
}

class CheckSessionInitial extends CheckSessionState {
  const CheckSessionInitial();
}

class CheckSessionLoading extends CheckSessionState {
  const CheckSessionLoading();
}

abstract class CheckSessionDone extends CheckSessionState {
  const CheckSessionDone();
}

class Authenticated extends CheckSessionDone {
  const Authenticated();
}

class Unauthenticated extends CheckSessionDone {
  const Unauthenticated();
}

abstract class CheckSessionFailed extends CheckSessionState {
  const CheckSessionFailed();
}
