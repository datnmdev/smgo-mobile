abstract class SessionState {
  const SessionState();
}

class CheckSessionInitial extends SessionState {
  const CheckSessionInitial();
}

class CheckSessionLoading extends SessionState {
  const CheckSessionLoading();
}

abstract class CheckSessionDone extends SessionState {
  const CheckSessionDone();
}

class Authenticated extends CheckSessionDone {
  const Authenticated();
}

class Unauthenticated extends CheckSessionDone {
  const Unauthenticated();
}

abstract class CheckSessionFailed extends SessionState {
  const CheckSessionFailed();
}
