import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';

abstract class SearchDeliveryOrdersState {
  final String searchText;

  const SearchDeliveryOrdersState({this.searchText = ''});
}

class SearchDeliveryOrdersInitial extends SearchDeliveryOrdersState {
  const SearchDeliveryOrdersInitial({super.searchText});
}

class SearchDeliveryOrdersLoading extends SearchDeliveryOrdersState {
  const SearchDeliveryOrdersLoading({super.searchText});
}

class SearchDeliveryOrdersDone extends SearchDeliveryOrdersState {
  final List<DeliveryOrderEntity> data;

  const SearchDeliveryOrdersDone({super.searchText, required this.data});
}

class SearchDeliveryOrdersError extends SearchDeliveryOrdersState {
  final Object error;

  const SearchDeliveryOrdersError({required this.error, super.searchText});
}
