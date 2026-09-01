import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/data/data_sources/delivery_route_api_service.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';
import 'package:smgo/shared/domain/entities/location_entity.dart';
import 'package:smgo/shared/domain/entities/media_entity.dart';
import 'package:smgo/shared/domain/entities/point_entity.dart';

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
                  totalDistance: e.totalDistance,
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
                          deliveredAt: order.deliveredAt,
                          cancelledAt: order.cancelledAt,
                          rescheduledAt: order.rescheduledAt,
                          appliedLocationId: order.appliedLocationId,
                          appliedLocation: order.appliedLocation != null
                              ? LocationEntity(
                                  id: order.appliedLocation!.id,
                                  locationName:
                                      order.appliedLocation!.locationName,
                                  contactName:
                                      order.appliedLocation!.contactName,
                                  contactPhone:
                                      order.appliedLocation!.contactPhone,
                                  media: order.appliedLocation!.media
                                      .map(
                                        (mediaModel) => MediaEntity(
                                          id: mediaModel.id,
                                          url: mediaModel.url,
                                        ),
                                      )
                                      .toList(),
                                  address: order.appliedLocation!.address,
                                  location: PointEntity(
                                    x: order.appliedLocation!.location.x,
                                    y: order.appliedLocation!.location.y,
                                  ),
                                  userId: order.appliedLocation!.userId,
                                  note: order.appliedLocation!.note,
                                  createdAt: order.appliedLocation!.createdAt,
                                  updatedAt: order.appliedLocation!.updatedAt,
                                )
                              : null,
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
  Future<DataState<DeliveryRouteEntity>> createDeliveryRouteWithOrders({
    required CreateDeliveryRouteWithOrdersParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService
          .createDeliveryRouteWithOrders(
            body: CreateDeliveryRouteWithOrdersBodyRequest(
              name: params.name,
              orders: params.orders
                  .map(
                    (order) => DeliveryOrderRequestData(
                      orderCode: order.orderCode,
                      orderName: order.orderName,
                      orderMediaId: order.orderMediaId,
                      contactName: order.contactName,
                      contactPhone: order.contactPhone,
                      address: order.address,
                      location: PointRequestData(
                        x: order.location.x,
                        y: order.location.y,
                      ),
                      appliedLocationId: order.appliedLocationId,
                    ),
                  )
                  .toList(),
            ),
          );
      final newDeliveryRouteModel = httpResponse.data.data!;
      return DataSuccess(
        DeliveryRouteEntity(
          id: newDeliveryRouteModel.id,
          name: newDeliveryRouteModel.name,
          status: newDeliveryRouteModel.status,
          totalOrders: newDeliveryRouteModel.totalOrders,
          totalCancelledOrders: newDeliveryRouteModel.totalCancelledOrders,
          totalCheckedOrders: newDeliveryRouteModel.totalCheckedOrders,
          totalPendingOrders: newDeliveryRouteModel.totalPendingOrders,
          totalSortedOrders: newDeliveryRouteModel.totalSortedOrders,
          totalRescheduledOrders: newDeliveryRouteModel.totalRescheduledOrders,
          totalDistance: newDeliveryRouteModel.totalDistance,
          totalDeliveredOrders: newDeliveryRouteModel.totalDeliveredOrders,
          orders: newDeliveryRouteModel.orders
              .map(
                (orderModel) => DeliveryOrderEntity(
                  id: orderModel.id,
                  orderCode: orderModel.orderCode,
                  orderName: orderModel.orderName,
                  orderMediaId: orderModel.orderMediaId,
                  orderMediaUrl: orderModel.orderMediaUrl,
                  sequenceOrder: orderModel.sequenceOrder,
                  status: orderModel.status,
                  contactName: orderModel.contactName,
                  contactPhone: orderModel.contactPhone,
                  address: orderModel.address,
                  location: Point(
                    x: orderModel.location.x,
                    y: orderModel.location.y,
                  ),
                  deliveryRouteId: orderModel.deliveryRouteId,
                  appliedLocationId: orderModel.appliedLocationId,
                  appliedLocation: orderModel.appliedLocation != null
                      ? LocationEntity(
                          id: orderModel.appliedLocation!.id,
                          locationName:
                              orderModel.appliedLocation!.locationName,
                          contactName: orderModel.appliedLocation!.contactName,
                          contactPhone:
                              orderModel.appliedLocation!.contactPhone,
                          media: orderModel.appliedLocation!.media
                              .map(
                                (mediaModel) => MediaEntity(
                                  id: mediaModel.id,
                                  url: mediaModel.url,
                                ),
                              )
                              .toList(),
                          address: orderModel.appliedLocation!.address,
                          location: PointEntity(
                            x: orderModel.appliedLocation!.location.x,
                            y: orderModel.appliedLocation!.location.y,
                          ),
                          userId: orderModel.appliedLocation!.userId,
                          note: orderModel.appliedLocation!.note,
                          createdAt: orderModel.appliedLocation!.createdAt,
                          updatedAt: orderModel.appliedLocation!.updatedAt,
                        )
                      : null,
                  createdAt: orderModel.createdAt,
                  updatedAt: orderModel.updatedAt,
                  checkedAt: orderModel.checkedAt,
                  sortedAt: orderModel.sortedAt,
                  deliveredAt: orderModel.deliveredAt,
                  cancelledAt: orderModel.cancelledAt,
                  rescheduledAt: orderModel.rescheduledAt,
                ),
              )
              .toList(),
          createdAt: newDeliveryRouteModel.createdAt,
          updatedAt: newDeliveryRouteModel.updatedAt,
        ),
      );
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
  Future<DataState<dynamic>> deleteDeliveryRoutes({
    required DeleteDeliveryRoutesParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.deleteDeliveryRoutes(
        body: DeleteDeliveryRoutesBodyRequest(
          deliveryRouteIds: params.deliveryRouteIds,
        ),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  // Delivery order
  @override
  Future<DataState<List<DeliveryOrderEntity>>> getDeliveryOrders({
    required GetDeliveryOrdersParams params,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService.getDeliveryOrders(
        deliveryRouteId: params.deliveryRouteId,
        queries: GetDeliveryOrdersQueryRequest(keyword: params.keyword),
      );
      return DataSuccess(
        httpResponse.data.data!
            .map(
              (deliveryOrderModel) => DeliveryOrderEntity(
                id: deliveryOrderModel.id,
                orderCode: deliveryOrderModel.orderCode,
                orderName: deliveryOrderModel.orderName,
                orderMediaId: deliveryOrderModel.orderMediaId,
                orderMediaUrl: deliveryOrderModel.orderMediaUrl,
                sequenceOrder: deliveryOrderModel.sequenceOrder,
                status: deliveryOrderModel.status,
                contactName: deliveryOrderModel.contactName,
                contactPhone: deliveryOrderModel.contactPhone,
                address: deliveryOrderModel.address,
                location: Point(
                  x: deliveryOrderModel.location.x,
                  y: deliveryOrderModel.location.y,
                ),
                deliveryRouteId: deliveryOrderModel.deliveryRouteId,
                appliedLocationId: deliveryOrderModel.appliedLocationId,
                appliedLocation: deliveryOrderModel.appliedLocation != null
                    ? LocationEntity(
                        id: deliveryOrderModel.appliedLocation!.id,
                        locationName:
                            deliveryOrderModel.appliedLocation!.locationName,
                        contactName:
                            deliveryOrderModel.appliedLocation!.contactName,
                        contactPhone:
                            deliveryOrderModel.appliedLocation!.contactPhone,
                        media: deliveryOrderModel.appliedLocation!.media
                            .map(
                              (mediaModel) => MediaEntity(
                                id: mediaModel.id,
                                url: mediaModel.url,
                              ),
                            )
                            .toList(),
                        address: deliveryOrderModel.appliedLocation!.address,
                        location: PointEntity(
                          x: deliveryOrderModel.appliedLocation!.location.x,
                          y: deliveryOrderModel.appliedLocation!.location.y,
                        ),
                        userId: deliveryOrderModel.appliedLocation!.userId,
                        note: deliveryOrderModel.appliedLocation!.note,
                        createdAt:
                            deliveryOrderModel.appliedLocation!.createdAt,
                        updatedAt:
                            deliveryOrderModel.appliedLocation!.updatedAt,
                      )
                    : null,
                createdAt: deliveryOrderModel.createdAt,
                updatedAt: deliveryOrderModel.updatedAt,
                checkedAt: deliveryOrderModel.checkedAt,
                sortedAt: deliveryOrderModel.sortedAt,
                deliveredAt: deliveryOrderModel.deliveredAt,
                cancelledAt: deliveryOrderModel.cancelledAt,
                rescheduledAt: deliveryOrderModel.rescheduledAt,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return DataFailed(e);
    }
  }

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
      final httpResponse = await deliveryRouteApiService.recheckDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: RecheckDeliveryOrdersBodyRequest(
          deliveryOrderIds: deliveryOrderIds,
        ),
      );
      return DataSuccess(httpResponse.data.data);
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
      final httpResponse = await deliveryRouteApiService.confirmDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: ConfirmDeliveryOrdersBodyRequest(
          deliveryOrderIds: deliveryOrderIds,
        ),
      );
      return DataSuccess(httpResponse.data.data);
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
      final httpResponse = await deliveryRouteApiService.sortDeliveryOrders(
        deliveryRouteId: deliveryRouteId,
        body: SortDeliveryOrdersBodyRequest(
          source: PointRequestData(x: source.x, y: source.y),
        ),
      );
      return DataSuccess(httpResponse.data.data);
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

  @override
  Future<DataState<dynamic>> confirmSortedDeliveryOrders({
    required String deliveryRouteId,
    required List<String> deliveryOrderIds,
  }) async {
    try {
      final httpResponse = await deliveryRouteApiService
          .confirmSortedDeliveryOrders(
            deliveryRouteId: deliveryRouteId,
            body: ConfirmSortedDeliveryOrdersBodyRequest(
              deliveryOrderIds: deliveryOrderIds,
            ),
          );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
