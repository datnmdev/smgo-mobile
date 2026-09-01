import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/entities/upload_url_entity.dart';
import 'package:smgo/shared/domain/repository/storage_repository.dart';

class GetUploadUrlUsecase
    implements Usecase<DataState<UploadUrlEntity>, void> {
  final StorageRepository storageRepository;

  const GetUploadUrlUsecase({required this.storageRepository});

  @override
  Future<DataState<UploadUrlEntity>> call({params}) {
    return storageRepository.getUploadUrl();
  }
}
