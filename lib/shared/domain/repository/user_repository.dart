import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<DataState<UserEntity>> getProfile();
}
