import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<DataState<UserEntity>> getProfile();
  Future<DataState<dynamic>> updateProfile({String? name, String? avatar});
}
