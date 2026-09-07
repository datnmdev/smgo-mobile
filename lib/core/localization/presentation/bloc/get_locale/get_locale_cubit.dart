import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/localization/domain/usecases/set_locale_usecase.dart';
import 'package:smgo/core/localization/presentation/bloc/get_locale/get_locale_state.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';

class GetLocaleCubit extends Cubit<GetLocaleState> {
  final GetLocaleUsecase _getLocaleUsecase;

  GetLocaleCubit({required GetLocaleUsecase getLocaleUsecase})
    : _getLocaleUsecase = getLocaleUsecase,
      super(const GetLocaleInitial());

  Future<void> call() async {
    emit(const GetLocaleLoading());
    final dataState = await _getLocaleUsecase.call(params: NoParams());
    if (dataState is DataSuccess) {
      emit(GetLocaleDone(locale: dataState.data));
    } else if (dataState is DataFailed) {
      emit(GetLocaleFailed(error: dataState.error!));
    }
  }
}
