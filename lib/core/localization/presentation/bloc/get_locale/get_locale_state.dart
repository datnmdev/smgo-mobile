import 'package:flutter/material.dart';

abstract class GetLocaleState {
  final Locale? locale;

  const GetLocaleState({this.locale});
}

class GetLocaleInitial extends GetLocaleState {
  const GetLocaleInitial();
}

class GetLocaleLoading extends GetLocaleState {
  const GetLocaleLoading();
}

class GetLocaleDone extends GetLocaleState {
  const GetLocaleDone({super.locale});
}

class GetLocaleFailed extends GetLocaleState {
  final Object error;

  const GetLocaleFailed({required this.error});
}
