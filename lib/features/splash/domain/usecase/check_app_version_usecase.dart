import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/core/utils/package_info_util.dart';
import 'package:shipgo/features/splash/domain/repository/app_version_repository.dart';

class CheckAppVersionUsecase
    implements Usecase<DataState<CheckAppVersionResult>, void> {
  final AppVersionRepository _appVersionRepository;

  const CheckAppVersionUsecase(this._appVersionRepository);

  @override
  Future<DataState<CheckAppVersionResult>> call({params}) async {
    final latestAppVersionDataState = await _appVersionRepository
        .getLatestAppVersion();
    if (latestAppVersionDataState is DataSuccess) {
      final latestAppVersion = latestAppVersionDataState.data!;
      if (latestAppVersion.isMaintenance) {
        return DataSuccess(
          Maintenance(
            messageMap: latestAppVersion.maintenanceMessage,
          ),
        );
      } else {
        final currentAppVersionName = await PackageInfoUtil.getVersionName();
        final currentBuild = await PackageInfoUtil.getBuildNumber();
        if (currentBuild < latestAppVersion.buildNumber) {
          if (currentBuild < latestAppVersion.minSupportedBuild) {
            return DataSuccess(
              UpdateRequired(
                currentAppVersionName: currentAppVersionName,
                newAppVersionName: latestAppVersion.versionName,
                isForceUpdate: true,
                storeAppId: latestAppVersion.storeAppId,
              ),
            );
          } else {
            return DataSuccess(
              UpdateRequired(
                currentAppVersionName: currentAppVersionName,
                newAppVersionName: latestAppVersion.versionName,
                isForceUpdate: false,
                storeAppId: latestAppVersion.storeAppId,
              ),
            );
          }
        } else {
          return DataSuccess(UpToDate());
        }
      }
    }
    return DataFailed(latestAppVersionDataState.error!);
  }
}

sealed class CheckAppVersionResult {
  const CheckAppVersionResult();
}

class UpdateRequired extends CheckAppVersionResult {
  final String currentAppVersionName;
  final String newAppVersionName;
  final String? storeAppId;
  final bool isForceUpdate;

  const UpdateRequired({
    required this.currentAppVersionName,
    required this.newAppVersionName,
    this.storeAppId,
    required this.isForceUpdate,
  });
}

class Maintenance extends CheckAppVersionResult {
  final Map<String, String>? messageMap;

  const Maintenance({this.messageMap});
}

class UpToDate extends CheckAppVersionResult {
  const UpToDate();
}
