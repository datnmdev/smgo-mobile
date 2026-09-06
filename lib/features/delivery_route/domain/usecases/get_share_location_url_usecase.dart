import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/delivery_route/domain/repository/share_location_repository.dart';

class GetShareLocationUrlUsecase
    implements Usecase<DataState<String>, GetShareLocationUrlUsecaseParams> {
  final ShareLocationRepository shareLocationRepository;
  GetShareLocationUrlUsecase({required this.shareLocationRepository});
  @override
  Future<DataState<String>> call({
    required GetShareLocationUrlUsecaseParams params,
  }) {
    return shareLocationRepository.getShareLocationUrl(
      deliveryRouteId: params.deliveryRouteId,
      deliveryOrderId: params.deliveryOrderId,
    );
  }
}

class GetShareLocationUrlUsecaseParams {
  final String deliveryRouteId;
  final String deliveryOrderId;

  GetShareLocationUrlUsecaseParams({
    required this.deliveryOrderId,
    required this.deliveryRouteId,
  });
}
