import 'package:flutter/material.dart';
import 'package:smgo/core/localization/data/data_sources/localization_data_source.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/resources/data_state.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationDataSource _localizationDataSource;
  final String _languageCodeKey = 'language_code';
  final String _countryCodeKey = 'country_code';
  Locale? _locale;

  LocalizationRepositoryImpl(LocalizationDataSource localizationDataSource)
    : _localizationDataSource = localizationDataSource;

  @override
  Future<DataState<Locale>> getLocale() async {
    try {
      final languageCode =
          await _localizationDataSource.get(_languageCodeKey) ?? 'vi';
      final countryCode =
          await _localizationDataSource.get(_countryCodeKey) ?? 'VN';
      return DataSuccess(_locale ?? Locale(languageCode, countryCode));
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> setLocale({required Locale locale}) async {
    try {
      _locale = locale;
      await _localizationDataSource.write(
        _languageCodeKey,
        locale.languageCode,
      );
      await _localizationDataSource.write(_countryCodeKey, locale.countryCode!);
      return DataSuccess(null);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
