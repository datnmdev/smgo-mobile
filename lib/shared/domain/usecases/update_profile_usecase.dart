import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/shared/domain/repository/user_repository.dart';

class UpdateProfileUsecase
    implements Usecase<DataState<dynamic>, UpdateProfileUsecaseParams> {
  final UserRepository userRepository;

  UpdateProfileUsecase({required this.userRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateProfileUsecaseParams params,
  }) {
    return userRepository.updateProfile(
      name: params.name,
      avatar: params.avatar,
    );
  }
}

class UpdateProfileUsecaseParams {
  final String? name;
  final String? avatar;

  UpdateProfileUsecaseParams({this.name, this.avatar});
}
