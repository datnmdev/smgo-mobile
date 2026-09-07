import 'package:flutter/material.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';

class SetLocaleUsecase
    implements Usecase<DataState<dynamic>, SetLocaleUsecaseParams> {
  final LocalizationRepository _localizationRepository;

  SetLocaleUsecase({required LocalizationRepository localizationRepository})
    : _localizationRepository = localizationRepository;

  @override
  Future<DataState<dynamic>> call({required SetLocaleUsecaseParams params}) {
    return _localizationRepository.setLocale(locale: params.locale);
  }
}

class SetLocaleUsecaseParams {
  final Locale locale;

  SetLocaleUsecaseParams({required this.locale});
}
