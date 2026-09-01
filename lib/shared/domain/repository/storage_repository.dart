import 'dart:typed_data';

import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/domain/entities/upload_url_entity.dart';

abstract interface class StorageRepository {
  Future<DataState<UploadUrlEntity>> getUploadUrl();
  Future<DataState<dynamic>> upload({
    required String presignedUploadUrl,
    required Uint8List fileBytes,
    required String mimeType,
  });
}
