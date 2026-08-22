import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_location_suggestions_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_location_suggestions/get_location_suggestions_state.dart';

class GetLocationSuggestionsCubit extends Cubit<GetLocationSuggestionsState> {
  final GetLocationSuggestionsUsecase getLocationSuggestionsUsecase;
  Timer? _timer;

  GetLocationSuggestionsCubit({required this.getLocationSuggestionsUsecase})
    : super(const GetLocationSuggestionsInitial());

  void call({required String contactPhone, required String address}) async {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 500), () async {
      emit(const GetLocationSuggestionsLoading());
      final dataState = await getLocationSuggestionsUsecase.call(
        params: GetLocationSuggestionsUsecaseParams(
          contactPhone: contactPhone,
          address: address,
          pageNumber: 1,
          pageSize: 10,
        ),
      );
      if (dataState is DataSuccess) {
        emit(GetLocationSuggestionsDone(locationSuggestions: dataState.data!));
      } else {
        emit(GetLocationSuggestionsError(error: dataState.error!));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
