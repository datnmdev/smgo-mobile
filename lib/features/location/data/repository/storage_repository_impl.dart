import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/data/data_sources/storage_api_service.dart';
import 'package:shipgo/features/location/domain/entities/upload_url_entity.dart';
import 'package:shipgo/features/location/domain/repository/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageApiService storageApiService;

  const StorageRepositoryImpl({required this.storageApiService});

  @override
  Future<DataState<UploadUrlEntity>> getUploadUrl() async {
    try {
      final dataState = await storageApiService.getUploadUrl();
      final uploadUrlModel = dataState.data.data!;
      return DataSuccess(
        UploadUrlEntity(
          uploadUrl: uploadUrlModel.uploadUrl,
          mediaId: uploadUrlModel.mediaId,
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }
}
