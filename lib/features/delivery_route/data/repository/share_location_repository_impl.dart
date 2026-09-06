import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/data/data_sources/share_location_api_service.dart';
import 'package:smgo/features/delivery_route/domain/repository/share_location_repository.dart';

class ShareLocationRepositoryImpl implements ShareLocationRepository {
  final ShareLocationApiService shareLocationApiService;

  ShareLocationRepositoryImpl({required this.shareLocationApiService});

  @override
  Future<DataState<String>> getShareLocationUrl({
    required String deliveryRouteId,
    required String deliveryOrderId,
  }) async {
    try {
      final httpResponse = await shareLocationApiService.getShareLocationUrl(
        query: GetShareLocationUrlQueryRequest(
          deliveryRouteId: deliveryRouteId,
          deliveryOrderId: deliveryOrderId,
        ),
      );
      return DataSuccess(httpResponse.data.data!);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
