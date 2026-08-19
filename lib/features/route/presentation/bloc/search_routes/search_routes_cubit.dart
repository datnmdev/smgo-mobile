import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/route/presentation/bloc/search_routes/search_routes_state.dart';

class SearchRoutesCubit extends Cubit<SearchRoutesState> {
  Timer? _debounceTimer;

  SearchRoutesCubit() : super(const SearchRoutesInitial());

  void searchTextChanged(String value) {
    emit(SearchRoutesInitial(searchText: value));
  }

  FutureOr<void> submit({required FutureOr<void> Function() cb}) async {
    _debounceTimer?.cancel();
    final completer = Completer<void>();
    _debounceTimer = Timer(Duration(seconds: 1), () async {
      emit(SearchRoutesLoading(searchText: state.searchText));
      try {
        await cb();
        emit(SearchRoutesDone(searchText: state.searchText));
        completer.complete();
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
        emit(SearchRoutesError(searchText: state.searchText, error: e));
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
