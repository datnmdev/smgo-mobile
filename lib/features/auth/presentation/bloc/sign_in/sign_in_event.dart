abstract class SignInEvent {
  const SignInEvent();
}

class SignInWithGoogle extends SignInEvent {
  const SignInWithGoogle();
}

class SignInWithFacebook extends SignInEvent {
  const SignInWithFacebook();
}
