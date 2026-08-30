import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/create_delivery_route_with_orders_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/create_delivery_route_with_orders/create_delivery_route_with_orders_state.dart';

class CreateDeliveryRouteWithOrdersCubit
    extends Cubit<CreateDeliveryRouteWithOrdersState> {
  final CreateDeliveryRouteWithOrdersUsecase
  createDeliveryRouteWithOrdersUsecase;

  CreateDeliveryRouteWithOrdersCubit({
    required this.createDeliveryRouteWithOrdersUsecase,
  }) : super(const CreateDeliveryRouteWithOrdersInitial());

  void call({
    required String routeName,
    required List<DeliveryOrderEntity> orders,
  }) async {
    emit(CreateDeliveryRouteWithOrdersLoading());
    final dataState = await createDeliveryRouteWithOrdersUsecase.call(
      params: CreateDeliveryRouteWithOrdersUsecaseParams(
        name: routeName,
        orders: orders
            .map(
              (order) => CreateDeliveryRouteWithOrdersUsecaseOrdersParam(
                orderCode: order.orderCode,
                orderName: order.orderName,
                orderMediaId: order.orderMediaId,
                contactName: order.contactName,
                contactPhone: order.contactPhone,
                address: order.address,
                location: order.location,
                appliedLocationId: order.appliedLocationId,
              ),
            )
            .toList(),
      ),
    );
    if (dataState is DataSuccess) {
      emit(
        CreateDeliveryRouteWithOrdersDone(newDeliveryRoute: dataState.data!),
      );
    } else if (dataState is DataFailed) {
      emit(CreateDeliveryRouteWithOrdersFailed(error: dataState.error!));
    }
  }
}
