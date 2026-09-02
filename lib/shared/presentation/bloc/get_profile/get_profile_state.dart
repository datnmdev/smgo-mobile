import 'package:smgo/shared/domain/entities/user_entity.dart';

abstract class GetProfileState {
  final UserEntity? profile;
  const GetProfileState({this.profile});
}

class GetProfileInitial extends GetProfileState {
  const GetProfileInitial();
}

class GetProfileLoading extends GetProfileState {
  const GetProfileLoading();
}

class GetProfileDone extends GetProfileState {
  const GetProfileDone({super.profile});
}

class GetProfileFailed extends GetProfileState {
  final Object error;

  const GetProfileFailed({required this.error});
}
