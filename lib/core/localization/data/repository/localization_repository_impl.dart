import 'package:flutter/material.dart';
import 'package:smgo/core/localization/data/data_sources/localization_data_source.dart';
import 'package:smgo/core/localization/domain/entities/locale_entity.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/resources/data_state.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationDataSource _localizationDataSource;
  final String _languageCodeKey = 'language_code';
  final String _countryCodeKey = 'country_code';

  LocalizationRepositoryImpl(LocalizationDataSource localizationDataSource)
    : _localizationDataSource = localizationDataSource;

  @override
  Future<DataState<Locale>> getLocale() async {
    try {
      final languageCode = await _localizationDataSource.get(_languageCodeKey);

      // Chưa từng chọn ngôn ngữ -> dùng ngôn ngữ hệ thống
      if (languageCode == null) {
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final locale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == systemLocale.languageCode,
          orElse: () => fallbackLocale,
        );
        return DataSuccess(locale);
      }

      // Đã có ngôn ngữ được lưu
      final countryCode = await _localizationDataSource.get(_countryCodeKey);
      final locale = supportedLocales.firstWhere(
        (locale) =>
            locale.languageCode == languageCode &&
            (countryCode == null || locale.countryCode == countryCode),
        orElse: () => supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
          orElse: () => fallbackLocale,
        ),
      );
      return DataSuccess(locale);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> setLocale({required Locale locale}) async {
    try {
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
