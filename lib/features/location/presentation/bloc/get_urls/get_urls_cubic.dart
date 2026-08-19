import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/location/domain/usecases/get_download_url_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/get_urls/get_urls_state.dart';

class GetUrlsCubit extends Cubit<GetUrlsState> {
  final GetDownloadUrlUsecase getDownloadUrlUsecase;

  GetUrlsCubit({required this.getDownloadUrlUsecase})
    : super(const GetUrlsInitial());

  Future<void> call(List<String> fileKeys) async {
    emit(const GetUrlsLoading());
    final dataStates = await Future.wait(
      fileKeys.map(
        (fileKey) => getDownloadUrlUsecase.call(
          params: GetDownloadUrlParams(fileKey: fileKey),
        ),
      ),
    );
    if (dataStates.any((dataState) => dataState is DataFailed)) {
      emit(
        GetUrlsFailed(
          errors: dataStates
              .whereType<DataFailed>()
              .map((dataState) => dataState.error!)
              .toList(),
        ),
      );
    } else {
      emit(
        GetUrlsDone(
          urls: dataStates.map((dataState) => dataState.data!).toList(),
        ),
      );
    }
  }
}
