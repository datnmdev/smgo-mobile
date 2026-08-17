import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/domain/entities/upload_url_entity.dart';

abstract interface class StorageRepository {
  Future<DataState<UploadUrlEntity>> getUploadUrl();
  Future<DataState<String>> getDownloadUrl({required String fileKey});
}
