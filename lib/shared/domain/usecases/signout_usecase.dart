import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/repository/session_repository.dart';

class SignoutUsecase implements Usecase<DataState<dynamic>, NoParams> {
  final SessionRepository sessionRepository;

  SignoutUsecase({required this.sessionRepository});

  @override
  Future<DataState<dynamic>> call({required NoParams params}) {
    return sessionRepository.signout();
  }
}
