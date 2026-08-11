import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';

class CheckAuthenticationUsecase implements Usecase<bool, void> {
  final TokenRepository _tokenRepository;

  const CheckAuthenticationUsecase(this._tokenRepository);

  @override
  Future<bool> call({params}) async {
    final accessToken = await _tokenRepository.getAccessToken();
    final refreshToken = await _tokenRepository.getRefreshToken();
    if (accessToken != null || refreshToken != null) {
      return true;
    }
    return false;
  }
}
