import 'package:dio/dio.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/utils/platform_util.dart';
import 'package:shipgo/features/splash/data/data_sources/app_version_api_service.dart';
import 'package:shipgo/features/splash/data/models/app_version_model.dart';
import 'package:shipgo/features/splash/domain/repository/app_version_repository.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionApiService _appVersionApiService;

  const AppVersionRepositoryImpl(this._appVersionApiService);

  @override
  Future<DataState<AppVersionModel>> getLatestAppVersion() async {
    try {
      final httpResponse = await _appVersionApiService.getLatestAppVersion(
        platform: PlatformUtil.getPlatformName(),
      );
      return DataSuccess(httpResponse.data.data!);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
