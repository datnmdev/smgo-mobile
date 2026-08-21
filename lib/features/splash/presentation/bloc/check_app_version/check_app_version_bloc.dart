import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/splash/domain/usecase/check_app_version_usecase.dart';
import 'package:shipgo/features/splash/presentation/bloc/check_app_version/check_app_version_event.dart';
import 'package:shipgo/features/splash/presentation/bloc/check_app_version/check_app_version_state.dart';

class CheckAppVersionBloc
    extends Bloc<CheckAppVersionEvent, CheckAppVersionState> {
  final CheckAppVersionUsecase checkAppVersionUsecase;

  CheckAppVersionBloc({required this.checkAppVersionUsecase})
    : super(const CheckAppVersionInitial()) {
    on<CheckAppVersion>(handleCheckVersion);
  }

  Future<void> handleCheckVersion(
    CheckAppVersion event,
    Emitter<CheckAppVersionState> emit,
  ) async {
    emit(CheckAppVersionLoading());
    final dataState = await checkAppVersionUsecase.call();
    if (dataState is DataSuccess) {
      final result = dataState.data!;
      if (result is Maintenance) {
        emit(CheckAppVersionMaintenance(messageMap: result.messageMap));
      } else if (result is UpdateRequired) {
        emit(
          CheckAppVersionUpdateRequired(
            currentAppVersionName: result.currentAppVersionName,
            newAppVersionName: result.newAppVersionName,
            isForceUpdate: result.isForceUpdate,
            storeAppId: result.storeAppId,
          ),
        );
      } else {
        emit(CheckAppVersionUpToDate());
      }
    } else {
      emit(CheckAppVersionFailed(error: dataState.error!));
    }
  }
}
