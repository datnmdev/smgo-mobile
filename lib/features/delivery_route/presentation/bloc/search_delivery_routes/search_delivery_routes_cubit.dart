import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_routes/search_delivery_routes_state.dart';

class SearchDeliveryRoutesCubit extends Cubit<SearchDeliveryRoutesState> {
  Timer? _debounceTimer;

  SearchDeliveryRoutesCubit() : super(const SearchDeliveryRoutesInitial());

  void searchTextChanged(String value) {
    emit(SearchDeliveryRoutesInitial(searchText: value));
  }

  FutureOr<void> submit({required FutureOr<void> Function() cb}) async {
    _debounceTimer?.cancel();
    final completer = Completer<void>();
    _debounceTimer = Timer(Duration(milliseconds: 400), () async {
      emit(SearchDeliveryRoutesLoading(searchText: state.searchText));
      try {
        await cb();
        emit(SearchDeliveryRoutesDone(searchText: state.searchText));
        completer.complete();
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
        emit(SearchDeliveryRoutesError(searchText: state.searchText, error: e));
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
