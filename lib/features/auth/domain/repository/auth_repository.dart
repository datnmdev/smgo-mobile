import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/auth/domain/entities/auth_token_entity.dart';

abstract class AuthRepository {
  Future<DataState<AuthTokensEntity>> signInWithGoogle();
  Future<DataState<AuthTokensEntity>> signInWithFacebook();
}
