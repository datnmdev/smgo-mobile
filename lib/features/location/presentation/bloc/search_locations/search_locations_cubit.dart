import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/location/presentation/bloc/search_locations/search_locations_state.dart';

class SearchLocationsCubit extends Cubit<SearchLocationsState> {
  Timer? _debounceTimer;

  SearchLocationsCubit() : super(const SearchLocationsInitial());

  void searchTextChanged(String value) {
    emit(SearchLocationsInitial(searchText: value));
  }

  FutureOr<void> submit({required FutureOr<void> Function() cb}) async {
    _debounceTimer?.cancel();
    final completer = Completer<void>();
    _debounceTimer = Timer(Duration(milliseconds: 400), () async {
      emit(SearchLocationsLoading(searchText: state.searchText));
      try {
        await cb();
        emit(SearchLocationsDone(searchText: state.searchText));
        completer.complete();
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
        emit(SearchLocationsError(searchText: state.searchText, error: e));
      }
    });
    return completer.future;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
