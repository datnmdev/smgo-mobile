import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';
import 'package:shipgo/features/auth/domain/repository/auth_repository.dart';

class SignInWithFacebookUsecase
    implements Usecase<DataState<AuthTokensEntity>, void> {
  final TokenRepository tokenRepository;
  final AuthRepository authRepository;

  const SignInWithFacebookUsecase({
    required this.authRepository,
    required this.tokenRepository,
  });

  @override
  Future<DataState<AuthTokensEntity>> call({params}) async {
    final dataState = await authRepository.signInWithFacebook();
    if (dataState is DataSuccess) {
      tokenRepository.saveAccessToken(dataState.data!.accessToken);
      tokenRepository.saveRefreshToken(dataState.data!.refreshToken);
    }
    return dataState;
  }
}
