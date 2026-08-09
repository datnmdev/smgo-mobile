import 'package:equatable/equatable.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';

abstract class SignInState extends Equatable {
  final AuthTokensEntity? authTokens;
  final dynamic error;

  const SignInState({this.authTokens, this.error});

  @override
  List<Object?> get props => [authTokens, error];
}

class SignInInitial extends SignInState {
  const SignInInitial();
}

class SignInLoading extends SignInState {
  const SignInLoading();
}

class SignInDone extends SignInState {
  const SignInDone(AuthTokensEntity authTokens) : super(authTokens: authTokens);
}

class SignInError extends SignInState {
  const SignInError(dynamic error) : super(error: error);
}
