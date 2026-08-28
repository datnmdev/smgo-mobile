import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/data/data_sources/delivery_route_api_service.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class DeliveryRouteRepositoryImpl implements DeliveryRouteRepository {
  final DeliveryRouteApiService deliveryRouteApiService;

  DeliveryRouteRepositoryImpl({required this.deliveryRouteApiService});

  @override
  Future<DataState<Pagination<DeliveryRouteEntity>>> getDeliveryRoutes({
    required GetDeliveryRoutesParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.getDeliveryRoutes(
        queries: GetDeliveryRoutesQueryRequest(
          keyword: params.keyword,
          pageNumber: params.pageNumber,
          pageSize: params.pageSize,
          id: params.id,
          status: params.status,
        ),
      );
      return DataSuccess(
        Pagination(
          meta: httpResponse.data.data!.meta,
          data: httpResponse.data.data!.data
              .map(
                (e) => DeliveryRouteEntity(
                  id: e.id,
                  name: e.name,
                  status: e.status,
                  totalOrders: e.totalOrders,
                  totalPendingOrders: e.totalPendingOrders,
                  totalCheckedOrders: e.totalCheckedOrders,
                  totalSortedOrders: e.totalSortedOrders,
                  totalDeliveredOrders: e.totalDeliveredOrders,
                  totalCancelledOrders: e.totalCancelledOrders,
                  totalRescheduledOrders: e.totalRescheduledOrders,
                  orders: e.orders
                      .map(
                        (order) => DeliveryOrderEntity(
                          id: order.id,
                          orderCode: order.orderCode,
                          orderName: order.orderName,
                          orderMediaId: order.orderMediaId,
                          orderMediaUrl: order.orderMediaUrl,
                          sequenceOrder: order.sequenceOrder,
                          status: order.status,
                          contactName: order.contactName,
                          contactPhone: order.contactPhone,
                          address: order.address,
                          location: Point(
                            x: order.location.x,
                            y: order.location.y,
                          ),
                          deliveryRouteId: order.deliveryRouteId,
                          createdAt: order.createdAt,
                          updatedAt: order.updatedAt,
                          checkedAt: order.checkedAt,
                          sortedAt: order.sortedAt,
                          deliveringAt: order.deliveredAt,
                          deliveredAt: order.deliveredAt,
                          cancelledAt: order.cancelledAt,
                          rescheduledAt: order.rescheduledAt,
                          appliedLocationId: order.appliedLocationId,
                        ),
                      )
                      .toList(),
                  createdAt: e.createdAt,
                  updatedAt: e.updatedAt,
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> addDeliveryRoute({
    required AddDeliveryRouteParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.addDeliveryRoute(
        body: AddDeliveryRouteBodyRequest(name: params.name),
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> updateDeliveryRoute({
    required String id,
    required UpdateDeliveryRouteParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.updateDeliveryRoute(
        id: id,
        body: UpdateDeliveryRouteBodyRequest(
          name: params.name,
          status: params.status,
        ),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> deleteDeliveryRoute({
    required DeleteDeliveryRouteParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.deleteDeliveryRoute(
        id: params.id,
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  // Delivery order
  @override
  Future<DataState<dynamic>> addDeliveryOrder({
    required AddDeliveryOrderParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.addDeliveryOrder(
        deliveryRouteId: params.deliveryRouteId,
        body: AddDeliveryOrderBodyRequest(
          orderCode: params.orderCode,
          orderName: params.orderName,
          orderMediaId: params.orderMediaId,
          contactName: params.contactName,
          contactPhone: params.contactPhone,
          address: params.address,
          appliedLocationId: params.appliedLocationId,
          location: PointRequestData(
            x: params.location.x,
            y: params.location.y,
          ),
        ),
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> updateDeliveryOrder({
    required UpdateDeliveryOrderParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.updateDeliveryOrder(
        deliveryRouteId: params.deliveryRouteId,
        deliveryOrderId: params.deliveryOrderId,
        body: UpdateDeliveryOrderBodyRequest(
          orderCode: params.orderCode,
          orderName: params.orderName,
          orderMediaId: params.orderMediaId,
          status: params.status,
          contactName: params.contactName,
          contactPhone: params.contactPhone,
          address: params.address,
          location: params.location != null
              ? PointRequestData(x: params.location!.x, y: params.location!.y)
              : null,
          appliedLocationId: params.appliedLocationId,
        ),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> recheckDeliveryOrders({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    try {
      final dataState = await deliveryRouteApiService.recheckDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: RecheckDeliveryOrdersBodyRequest(
          deliveryOrderIds: deliveryOrderIds,
        ),
      );
      return DataSuccess(dataState.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> confirmDeliveryOrders({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    try {
      final dataState = await deliveryRouteApiService.confirmDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: ConfirmDeliveryOrdersBodyRequest(
          deliveryOrderIds: deliveryOrderIds,
        ),
      );
      return DataSuccess(dataState.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> sortDeliveryOrders({
    required String deliveryRouteId,
    required Point source,
  }) async {
    try {
      final dataState = await deliveryRouteApiService.sortDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: SortDeliveryOrdersBodyRequest(
          source: PointRequestData(x: source.x, y: source.y),
        ),
      );
      return DataSuccess(dataState.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> deleteDeliveryOrders({
    required DeleteDeliveryOrdersParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.deleteDeliveryOrders(
        deliveryRouteId: params.deliveryRouteId,
        body: DeleteDeliveryOrdersBodyRequest(
          deliveryOrderIds: params.deliveryOrderIds,
        ),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
