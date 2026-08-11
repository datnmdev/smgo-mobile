import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/splash/domain/entities/app_version_entity.dart';

abstract class AppVersionRepository {
  Future<DataState<AppVersionEntity>> getLatestAppVersion();
}