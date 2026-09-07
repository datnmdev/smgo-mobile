import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/localization/domain/usecases/get_locale_usecase.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_state.dart';
import 'package:smgo/core/resources/data_state.dart';

class SetLocaleCubit extends Cubit<SetLocaleState> {
  final SetLocaleUsecase _setLocaleUsecase;

  SetLocaleCubit({required SetLocaleUsecase setLocaleUsecase})
    : _setLocaleUsecase = setLocaleUsecase,
      super(const SetLocaleInitial());

  void call({required Locale locale}) async {
    emit(const SetLocaleLoading());
    final dataState = await _setLocaleUsecase.call(
      params: SetLocaleUsecaseParams(locale: locale),
    );
    if (dataState is DataSuccess) {
      emit(SetLocaleDone());
    } else if (dataState is DataFailed) {
      emit(SetLocaleFailed(error: dataState.error!));
    }
  }
}
