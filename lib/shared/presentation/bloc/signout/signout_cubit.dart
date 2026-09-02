import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/usecases/signout_usecase.dart';
import 'package:smgo/shared/presentation/bloc/signout/signout_state.dart';

class SignoutCubit extends Cubit<SignoutState> {
  final SignoutUsecase signoutUsecase;

  SignoutCubit({required this.signoutUsecase}) : super(const SignoutInitial());

  void call() async {
    emit(const SignoutLoading());
    final dataState = await signoutUsecase.call(params: NoParams());
    if (dataState is DataSuccess) {
      emit(const SignoutDone());
    } else if (dataState is DataFailed) {
      emit(SignoutFailed(error: dataState.error!));
    }
  }
}
