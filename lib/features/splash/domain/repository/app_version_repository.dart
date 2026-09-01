import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/splash/domain/entities/app_version_entity.dart';

abstract class AppVersionRepository {
  Future<DataState<AppVersionEntity>> getLatestAppVersion();
}