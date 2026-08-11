import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/auth/domain/usecases/check_authentication_usecase.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_event.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_state.dart';

class SessionBloc extends Bloc<SessionEvent,SessionState> {
  final CheckAuthenticationUsecase _checkAuthenticationUsecase;

  SessionBloc(this._checkAuthenticationUsecase): super(const CheckSessionInitial()) {
    on<CheckSession>(handleCheckSession);
  }

  void handleCheckSession(CheckSession event, Emitter<SessionState> emit) async {
    emit(const CheckSessionLoading());
    final isAuthenticated = await _checkAuthenticationUsecase.call();
    if (isAuthenticated) {
      emit(const Authenticated());
    } else {
      emit(const Unauthenticated());
    }
  }
}