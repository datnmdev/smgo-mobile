import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';

class CheckAuthenticationUsecase implements Usecase<bool, void> {
  final TokenRepository tokenRepository;

  const CheckAuthenticationUsecase({required this.tokenRepository});

  @override
  Future<bool> call({params}) async {
    final accessToken = await tokenRepository.getAccessToken();
    final refreshToken = await tokenRepository.getRefreshToken();
    if (accessToken != null || refreshToken != null) {
      return true;
    }
    return false;
  }
}
