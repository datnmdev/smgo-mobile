import 'package:flutter/material.dart';
import 'package:shipgo/core/localization/data/data_sources/localization_data_source.dart';
import 'package:shipgo/core/localization/domain/repository/localization_repository.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationDataSource _localizationDataSource;
  final String _languageCodeKey = 'language_code';
  final String _countryCodeKey = 'country_code';
  Locale? _locale;

  LocalizationRepositoryImpl(LocalizationDataSource localizationDataSource)
    : _localizationDataSource = localizationDataSource;

  @override
  Future<Locale> getLocale() async {
    final languageCode =
        await _localizationDataSource.get(_languageCodeKey) ?? 'vi';
    final countryCode =
        await _localizationDataSource.get(_countryCodeKey) ?? 'VN';
    return _locale ?? Locale(languageCode, countryCode);
  }

  @override
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _localizationDataSource.write(_languageCodeKey, locale.languageCode);
    await _localizationDataSource.write(_countryCodeKey, locale.countryCode!);
  }

  @override
  Future<String> getLocaleTag() async {
    final Locale locale = await getLocale();
    return '${locale.languageCode}-${locale.countryCode}';
  }
}
