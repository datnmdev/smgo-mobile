import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';

abstract class AuthRepository {
  Future<DataState<AuthTokensEntity>> signInWithGoogle();
}
