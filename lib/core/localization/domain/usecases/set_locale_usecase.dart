import 'package:flutter/material.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';

class GetLocaleUsecase implements Usecase<DataState<Locale>, NoParams> {
  final LocalizationRepository _localizationRepository;

  GetLocaleUsecase({required LocalizationRepository localizationRepository})
    : _localizationRepository = localizationRepository;

  @override
  Future<DataState<Locale>> call({required NoParams params}) {
    return _localizationRepository.getLocale();
  }
}
