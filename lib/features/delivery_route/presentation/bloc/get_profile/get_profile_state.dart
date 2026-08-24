import 'package:shipgo/shared/domain/entities/user_entity.dart';

abstract class GetProfileState {
  const GetProfileState();
}

class GetProfileInitial extends GetProfileState {
  const GetProfileInitial();
}

class GetProfileLoading extends GetProfileState {
  const GetProfileLoading();
}

class GetProfileDone extends GetProfileState {
  final UserEntity profile;

  const GetProfileDone({required this.profile});
}

class GetProfileFailed extends GetProfileState {
  final Object error;

  const GetProfileFailed({required this.error});
}
