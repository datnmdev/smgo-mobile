import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/shared/domain/entities/upload_url_entity.dart';
import 'package:shipgo/shared/domain/repository/storage_repository.dart';

class GetUploadUrlUsecase
    implements Usecase<DataState<UploadUrlEntity>, void> {
  final StorageRepository storageRepository;

  const GetUploadUrlUsecase({required this.storageRepository});

  @override
  Future<DataState<UploadUrlEntity>> call({params}) {
    return storageRepository.getUploadUrl();
  }
}
