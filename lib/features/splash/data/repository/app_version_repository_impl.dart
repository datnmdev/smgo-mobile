import 'package:dio/dio.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/utils/platform_util.dart';
import 'package:smgo/features/splash/data/data_sources/app_version_api_service.dart';
import 'package:smgo/features/splash/data/models/app_version_model.dart';
import 'package:smgo/features/splash/domain/repository/app_version_repository.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionApiService appVersionApiService;

  const AppVersionRepositoryImpl({required this.appVersionApiService});

  @override
  Future<DataState<AppVersionModel>> getLatestAppVersion() async {
    try {
      final httpResponse = await appVersionApiService.getLatestAppVersion(
        platform: PlatformUtil.getPlatformName(),
      );
      return DataSuccess(httpResponse.data.data!);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
