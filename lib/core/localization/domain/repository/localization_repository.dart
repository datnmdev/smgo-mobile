import 'package:flutter/material.dart';

abstract class LocalizationRepository {
  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);
  Future<String> getLocaleTag();
}
