import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/features/auth/domain/usecases/check_authentication_usecase.dart';
import 'package:smgo/features/splash/presentation/bloc/check_session/check_session_state.dart';

class CheckSessionCubit extends Cubit<CheckSessionState> {
  final CheckAuthenticationUsecase checkAuthenticationUsecase;

  CheckSessionCubit({required this.checkAuthenticationUsecase})
    : super(const CheckSessionInitial());

  void call() async {
    emit(const CheckSessionLoading());
    final isAuthenticated = await checkAuthenticationUsecase.call();
    if (isAuthenticated) {
      emit(const Authenticated());
    } else {
      emit(const Unauthenticated());
    }
  }
}
