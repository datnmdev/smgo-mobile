import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/location/presentation/bloc/search_locations/search_locations_state.dart';

class SearchLocationsCubit extends Cubit<SearchLocationsState> {
  Timer? _debounceTimer;

  SearchLocationsCubit() : super(const SearchLocationsState());

  void call({required String searchText, void Function()? cb}) {
    emit(SearchLocationsState(searchText: searchText));
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      if (cb != null) {
        cb();
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
