import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/location/domain/repository/storage_repository.dart';

class GetDownloadUrlUsecase
    implements Usecase<DataState<String>, GetDownloadUrlParams> {
  final StorageRepository storageRepository;

  const GetDownloadUrlUsecase({required this.storageRepository});

  @override
  Future<DataState<String>> call({required GetDownloadUrlParams params}) {
    return storageRepository.getDownloadUrl(fileKey: params.fileKey);
  }
}

class GetDownloadUrlParams {
  final String fileKey;

  const GetDownloadUrlParams({required this.fileKey});
}
