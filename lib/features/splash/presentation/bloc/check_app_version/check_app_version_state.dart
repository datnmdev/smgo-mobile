import 'package:equatable/equatable.dart';

abstract class CheckAppVersionState extends Equatable {
  const CheckAppVersionState();

  @override
  List<Object?> get props => [];
}

class CheckAppVersionInitial extends CheckAppVersionState {
  const CheckAppVersionInitial();
}

class CheckAppVersionLoading extends CheckAppVersionState {
  const CheckAppVersionLoading();
}

abstract class CheckAppVersionDone extends CheckAppVersionState {
  const CheckAppVersionDone();
}

class CheckAppVersionUpdateRequired extends CheckAppVersionDone {
  final String currentAppVersionName;
  final String newAppVersionName;
  final String? storeAppId;
  final bool isForceUpdate;

  const CheckAppVersionUpdateRequired({
    required this.currentAppVersionName,
    required this.newAppVersionName,
    this.storeAppId,
    required this.isForceUpdate,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    currentAppVersionName,
    newAppVersionName,
    storeAppId,
    isForceUpdate,
  ];
}

class CheckAppVersionMaintenance extends CheckAppVersionDone {
  final Map<String, String>? messageMap;

  const CheckAppVersionMaintenance({this.messageMap});

  @override
  List<Object?> get props => [...super.props, messageMap];
}

class CheckAppVersionUpToDate extends CheckAppVersionDone {
  const CheckAppVersionUpToDate();

  @override
  List<Object?> get props => [...super.props];
}

class CheckAppVersionFailed extends CheckAppVersionState {
  final Object error;

  const CheckAppVersionFailed({required this.error});

  @override
  List<Object?> get props => [...super.props, error];
}
