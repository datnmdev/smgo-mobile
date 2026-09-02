import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/core/security/token/domain/repository/token_repository.dart';

class ClearTokenUsecase implements Usecase<DataState<dynamic>, NoParams> {
  final TokenRepository tokenRepository;

  ClearTokenUsecase({required this.tokenRepository});

  @override
  Future<DataState<dynamic>> call({required NoParams params}) {
    return tokenRepository.clearToken();
  }
}
