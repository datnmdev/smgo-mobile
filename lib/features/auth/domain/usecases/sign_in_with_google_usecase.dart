import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUsecase
    implements Usecase<DataState<AuthTokensEntity>, void> {
  final AuthRepository _authRepository;

  const SignInWithGoogleUsecase(this._authRepository);

  @override
  Future<DataState<AuthTokensEntity>> call({params}) {
    return _authRepository.signInWithGoogle();
  }
}
