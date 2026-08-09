import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInWithGoogleUsecase _signInWithGoogleUsecase;

  SignInBloc({required SignInWithGoogleUsecase signInWithGoogleUsecase})
    : _signInWithGoogleUsecase = signInWithGoogleUsecase,
      super(const SignInInitial()) {
    on<SignInWithGoogle>(onSignInWithGoogle);
  }

  Future<void> onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());
    final dataState = await _signInWithGoogleUsecase.call();
    if (dataState is DataSuccess) {
      emit(SignInDone(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(SignInError(dataState.error!));
    }
  }
}
