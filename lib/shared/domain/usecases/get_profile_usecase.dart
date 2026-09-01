import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/entities/user_entity.dart';
import 'package:smgo/shared/domain/repository/user_repository.dart';

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
