import 'package:flutter/material.dart';
import 'package:smgo/core/resources/data_state.dart';

abstract class LocalizationRepository {
  Future<DataState<Locale>> getLocale();
  Future<DataState<dynamic>> setLocale({required Locale locale});
}
