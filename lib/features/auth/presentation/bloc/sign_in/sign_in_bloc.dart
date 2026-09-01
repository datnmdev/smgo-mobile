import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/auth/domain/usecases/sign_in_with_facebook_usecase.dart';
import 'package:smgo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInWithGoogleUsecase signInWithGoogleUsecase;
  final SignInWithFacebookUsecase signInWithFacebookUsecase;

  SignInBloc({
    required this.signInWithGoogleUsecase,
    required this.signInWithFacebookUsecase,
  }) : super(const SignInInitial()) {
    on<SignInWithGoogle>(onSignInWithGoogle);
    on<SignInWithFacebook>(onSignInWithFacebook);
  }

  Future<void> onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());
    final dataState = await signInWithGoogleUsecase.call();
    if (dataState is DataSuccess) {
      emit(SignInDone(dataState.data!));
    } else {
      emit(SignInError(dataState.error!));
    }
  }

  Future<void> onSignInWithFacebook(
    SignInWithFacebook event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());
    final dataState = await signInWithFacebookUsecase.call();
    if (dataState is DataSuccess) {
      emit(SignInDone(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(SignInError(dataState.error!));
    }
  }
}
