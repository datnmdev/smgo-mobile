abstract class SignoutState {
  const SignoutState();
}

class SignoutInitial extends SignoutState {
  const SignoutInitial();
}

class SignoutLoading extends SignoutState {
  const SignoutLoading();
}

class SignoutDone extends SignoutState {
  const SignoutDone();
}

class SignoutFailed extends SignoutState {
  final Object error;
  const SignoutFailed({required this.error});
}
