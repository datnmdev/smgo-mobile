import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';

class SignInWithFacebookUsecase
    implements Usecase<DataState<AuthTokensEntity>, void> {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  const SignInWithFacebookUsecase({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  }) : _authRepository = authRepository,
       _tokenRepository = tokenRepository;

  @override
  Future<DataState<AuthTokensEntity>> call({params}) async {
    final dataState = await _authRepository.signInWithFacebook();
    if (dataState is DataSuccess) {
      _tokenRepository.saveAccessToken(dataState.data!.accessToken);
      _tokenRepository.saveRefreshToken(dataState.data!.refreshToken);
    }
    return dataState;
  }
}
