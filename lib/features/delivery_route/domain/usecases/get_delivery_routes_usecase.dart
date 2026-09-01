import 'package:smgo/core/network/api_response.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class GetDeliveryRoutesUsecase
    implements
        Usecase<
          DataState<Pagination<DeliveryRouteEntity>>,
          GetDeliveryRoutesUsecaseParams
        > {
  final DeliveryRouteRepository deliveryRouteRepository;

  GetDeliveryRoutesUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<Pagination<DeliveryRouteEntity>>> call({
    required GetDeliveryRoutesUsecaseParams params,
  }) {
    return deliveryRouteRepository.getDeliveryRoutes(
      params: GetDeliveryRoutesParams(
        id: params.id,
        status: params.status,
        keyword: params.keyword,
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
      ),
    );
  }
}

class GetDeliveryRoutesUsecaseParams {
  final String? keyword;
  final String? status;
  final String? id;
  final int? pageNumber;
  final int? pageSize;

  GetDeliveryRoutesUsecaseParams({
    this.keyword,
    this.status,
    this.id,
    this.pageNumber,
    this.pageSize,
  });
}
