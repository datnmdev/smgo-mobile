import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_state.dart';
import 'package:smgo/shared/domain/usecases/get_profile_usecase.dart';

class GetProfileCubit extends Cubit<GetProfileState> {
  final GetProfileUsecase getProfileUsecase;

  GetProfileCubit({required this.getProfileUsecase})
    : super(const GetProfileInitial());

  Future<void> call() async {
    emit(const GetProfileLoading());
    final dataState = await getProfileUsecase.call(
      params: GetProfileUsecaseParams(),
    );
    if (dataState is DataSuccess) {
      emit(GetProfileDone(profile: dataState.data!));
    } else if (dataState is DataFailed) {
      emit(GetProfileFailed(error: dataState.error!));
    }
  }
}
