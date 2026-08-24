import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/data/data_sources/local/user_local_service.dart';
import 'package:shipgo/shared/data/data_sources/remote/user_api_service.dart';
import 'package:shipgo/shared/domain/entities/user_entity.dart';
import 'package:shipgo/shared/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService userApiService;
  final UserLocalService userLocalService;

  UserRepositoryImpl({
    required this.userApiService,
    required this.userLocalService,
  });

  @override
  Future<DataState<UserEntity>> getProfile() async {
    try {
      final userModel = await userLocalService.getProfile();
      if (userModel != null) {
        return DataSuccess(
          UserEntity(
            id: userModel.id,
            name: userModel.name,
            provider: userModel.provider,
            uuid: userModel.uuid,
            createdAt: userModel.createdAt,
          ),
        );
      }
      final dataState = await userApiService.getProfile();
      await userLocalService.saveProfile(userModel: dataState.data.data!);
      return DataSuccess(
        UserEntity(
          id: dataState.data.data!.id,
          name: dataState.data.data!.name,
          provider: dataState.data.data!.provider,
          uuid: dataState.data.data!.uuid,
          createdAt: dataState.data.data!.createdAt,
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }
}
