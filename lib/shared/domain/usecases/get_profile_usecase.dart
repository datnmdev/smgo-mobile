import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/shared/domain/entities/user_entity.dart';
import 'package:shipgo/shared/domain/repository/user_repository.dart';

class GetProfileUsecase
    implements Usecase<DataState<UserEntity>, GetProfileUsecaseParams> {
  final UserRepository userRepository;

  GetProfileUsecase({required this.userRepository});

  @override
  Future<DataState<UserEntity>> call({
    required GetProfileUsecaseParams params,
  }) {
    return userRepository.getProfile();
  }
}

class GetProfileUsecaseParams {}
