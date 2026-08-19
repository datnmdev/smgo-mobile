import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/route/data/data_sources/route_api_service.dart';
import 'package:shipgo/features/route/domain/entities/route_entity.dart';
import 'package:shipgo/features/route/domain/repository/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteApiService routeApiService;

  RouteRepositoryImpl({required this.routeApiService});

  @override
  Future<DataState<Pagination<RouteEntity>>> getMyRoutes({
    required GetMyRoutesParams params,
  }) async {
    try {
      final httpResponse = await routeApiService.getMyRoutes(
        queries: GetMyRoutesQueryRequest(
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
                (e) => RouteEntity(
                  id: e.id,
                  name: e.name,
                  status: e.status,
                  totalOrders: e.totalOrders,
                  totalPendingOrders: e.totalPendingOrders,
                  totalCheckedOrders: e.totalCheckedOrders,
                  totalDeliveredOrders: e.totalDeliveredOrders,
                  totalCanceledOrders: e.totalCanceledOrders,
                  totalRescheduledOrders: e.totalRescheduledOrders,
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
  Future<DataState<dynamic>> addRoute({required AddRouteParams params}) async {
    try {
      final httpResponse = await routeApiService.addRoute(
        body: AddRouteBodyRequest(name: params.name),
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> updateMyRoute({
    required String id,
    required UpdateMyRouteParams params,
  }) async {
    try {
      final httpResponse = await routeApiService.updateMyRoute(
        id: id,
        body: UpdateMyRouteBodyRequest(name: params.name),
      );
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<dynamic>> deleteMyRoute({
    required DeleteMyRouteParams params,
  }) async {
    try {
      final httpResponse = await routeApiService.deleteMyRoute(id: params.id);
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
