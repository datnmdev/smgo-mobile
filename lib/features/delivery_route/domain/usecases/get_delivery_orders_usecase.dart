import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/repository/delivery_route_repository.dart';

class GetDeliveryOrdersUsecase
    implements
        Usecase<
          DataState<List<DeliveryOrderEntity>>,
          GetDeliveryOrdersUsecaseParams
        > {
  final DeliveryRouteRepository deliveryRouteRepository;

  GetDeliveryOrdersUsecase({required this.deliveryRouteRepository});

  @override
  Future<DataState<List<DeliveryOrderEntity>>> call({
    required GetDeliveryOrdersUsecaseParams params,
  }) {
    return deliveryRouteRepository.getDeliveryOrders(
      params: GetDeliveryOrdersParams(
        keyword: params.keyword,
        deliveryRouteId: params.deliveryRouteId
      ),
    );
  }
}

class GetDeliveryOrdersUsecaseParams {
  final String? keyword;
  final String deliveryRouteId;

  GetDeliveryOrdersUsecaseParams({this.keyword, required this.deliveryRouteId});
}
