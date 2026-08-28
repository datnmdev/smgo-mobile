import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/data/data_sources/remote/storage_api_service.dart';
import 'package:shipgo/shared/domain/entities/upload_url_entity.dart';
import 'package:shipgo/shared/domain/repository/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageApiService storageApiService;

  const StorageRepositoryImpl({required this.storageApiService});

  @override
  Future<DataState<UploadUrlEntity>> getUploadUrl() async {
    try {
      final httpResponse = await storageApiService.getUploadUrl();
      final uploadUrlModel = httpResponse.data.data!;
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

  @override
  Future<DataState<dynamic>> upload({
    required String presignedUploadUrl,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    try {
      final httpResponse = await Dio().put(
        presignedUploadUrl,
        data: fileBytes,
        options: Options(headers: {'Content-Type': mimeType}),
      );
      return DataSuccess(httpResponse.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
