import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/route/domain/entities/route_entity.dart';
import 'package:shipgo/features/route/domain/repository/route_repository.dart';

class GetMyRoutesUsecase
    implements
        Usecase<DataState<Pagination<RouteEntity>>, GetMyRoutesUsecaseParams> {
  final RouteRepository routeRepository;

  GetMyRoutesUsecase({required this.routeRepository});

  @override
  Future<DataState<Pagination<RouteEntity>>> call({
    required GetMyRoutesUsecaseParams params,
  }) {
    return routeRepository.getMyRoutes(
      params: GetMyRoutesParams(
        id: params.id,
        status: params.status,
        keyword: params.keyword,
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
      ),
    );
  }
}

class GetMyRoutesUsecaseParams {
  final String? keyword;
  final String? status;
  final String? id;
  final int? pageNumber;
  final int? pageSize;

  GetMyRoutesUsecaseParams({
    this.keyword,
    this.status,
    this.id,
    this.pageNumber,
    this.pageSize,
  });
}
