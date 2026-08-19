import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/route/domain/entities/route_entity.dart';

class AddRouteParams {
  final String name;

  const AddRouteParams({required this.name});
}

class GetMyRoutesParams {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;
  final String? status;

  GetMyRoutesParams({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
    this.status,
  });
}

class UpdateMyRouteParams {
  final String? name;

  UpdateMyRouteParams({this.name});
}

class DeleteMyRouteParams {
  final String id;

  DeleteMyRouteParams({required this.id});
}

abstract class RouteRepository {
  Future<DataState<Pagination<RouteEntity>>> getMyRoutes({
    required GetMyRoutesParams params,
  });
  Future<DataState<dynamic>> addRoute({required AddRouteParams params});
  Future<DataState<dynamic>> updateMyRoute({
    required String id,
    required UpdateMyRouteParams params,
  });
  Future<DataState<dynamic>> deleteMyRoute({
    required DeleteMyRouteParams params,
  });
}
