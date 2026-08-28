import 'dart:typed_data';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/shared/domain/repository/storage_repository.dart';

class UploadMediaUsecase
    implements Usecase<DataState<dynamic>, UploadMediaParams> {
  final StorageRepository storageRepository;

  const UploadMediaUsecase({required this.storageRepository});

  @override
  Future<DataState<dynamic>> call({required UploadMediaParams params}) async {
    return storageRepository.upload(
      presignedUploadUrl: params.presignedUploadUrl,
      fileBytes: params.fileBytes,
      mimeType: params.mimeType,
    );
  }
}

class UploadMediaParams {
  final String presignedUploadUrl;
  final String mimeType;
  final Uint8List fileBytes;

  const UploadMediaParams({
    required this.presignedUploadUrl,
    required this.mimeType,
    required this.fileBytes,
  });
}
