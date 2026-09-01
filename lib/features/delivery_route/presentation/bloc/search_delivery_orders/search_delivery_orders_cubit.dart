import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/usecases/get_delivery_orders_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/search_delivery_orders/search_delivery_orders_state.dart';

class SearchDeliveryOrdersCubit extends Cubit<SearchDeliveryOrdersState> {
  final GetDeliveryOrdersUsecase getDeliveryOrdersUsecase;
  Timer? _debounceTimer;

  SearchDeliveryOrdersCubit({required this.getDeliveryOrdersUsecase})
    : super(const SearchDeliveryOrdersInitial());

  void reset() {
    emit(SearchDeliveryOrdersInitial(searchText: ''));
  }

  void searchTextChanged(String value) {
    emit(SearchDeliveryOrdersInitial(searchText: value));
  }

  FutureOr<void> submit({required String deliveryRouteId}) async {
    _debounceTimer?.cancel();
    final completer = Completer<void>();
    _debounceTimer = Timer(Duration(milliseconds: 400), () async {
      emit(SearchDeliveryOrdersLoading(searchText: state.searchText));
      final dataState = await getDeliveryOrdersUsecase.call(
        params: GetDeliveryOrdersUsecaseParams(
          deliveryRouteId: deliveryRouteId,
          keyword: state.searchText,
        ),
      );
      if (dataState is DataSuccess) {
        emit(
          SearchDeliveryOrdersDone(
            searchText: state.searchText,
            data: dataState.data!,
          ),
        );
        completer.complete();
      } else if (dataState is DataFailed) {
        completer.completeError(dataState.error!);
        emit(
          SearchDeliveryOrdersError(
            searchText: state.searchText,
            error: dataState.error!,
          ),
        );
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
