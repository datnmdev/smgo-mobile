import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delivery_order_page/delivery_order_page_state.dart';

class DeliveryOrderPageCubit extends Cubit<DeliveryOrderPageState> {
  DeliveryOrderPageCubit(): super(DeliveryOrderPageState());

  void tabChanged({required DeliveryOrderPageTab tab}) {
    emit(state.copyWith(selectedTab: tab));
  }
}