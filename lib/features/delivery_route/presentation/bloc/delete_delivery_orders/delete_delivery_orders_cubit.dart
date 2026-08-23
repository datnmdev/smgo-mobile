import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/delete_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_orders/delete_delivery_orders_state.dart';

class DeleteDeliveryOrdersCubit extends Cubit<DeleteDeliveryOrdersState> {
  final DeleteDeliveryOrderUsecase deleteDeliveryOrderUsecase;

  DeleteDeliveryOrdersCubit({required this.deleteDeliveryOrderUsecase})
    : super(const DeleteDeliveryOrdersInitial());

  Future<void> call(List<DeliveryOrderEntity> orders) async {
    emit(const DeleteDeliveryOrdersLoading());
    await Future.wait(
      orders.map(
        (order) => deleteDeliveryOrderUsecase.call(
          params: DeleteDeliveryOrderUsecaseParams(
            deliveryRouteId: order.deliveryRouteId,
            deliveryOrderId: order.id,
          ),
        ),
      ),
    );
    emit(const DeleteDeliveryOrdersDone());
  }
}
