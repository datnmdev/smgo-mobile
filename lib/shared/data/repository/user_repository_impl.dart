import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/data/data_sources/user_api_service.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';
import 'package:smgo/shared/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService userApiService;

  UserRepositoryImpl({required this.userApiService});

  @override
  Future<DataState<UserEntity>> getProfile() async {
    try {
      final httpRespose = await userApiService.getProfile();
      final userModel = httpRespose.data.data!;
      return DataSuccess(
        UserEntity(
          id: userModel.id,
          name: userModel.name,
          provider: userModel.provider,
          uuid: userModel.uuid,
          avatar: userModel.avatar,
          avatarUrl: userModel.avatarUrl,
          createdAt: userModel.createdAt,
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    try {
      final httpResponse = await userApiService.updateProfile(
        body: UpdateProfileBodyRequest(name: name, avatar: avatar),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
