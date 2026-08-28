import 'dart:typed_data';

import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/domain/entities/upload_url_entity.dart';

abstract interface class StorageRepository {
  Future<DataState<UploadUrlEntity>> getUploadUrl();
  Future<DataState<dynamic>> upload({
    required String presignedUploadUrl,
    required Uint8List fileBytes,
    required String mimeType,
  });
}
