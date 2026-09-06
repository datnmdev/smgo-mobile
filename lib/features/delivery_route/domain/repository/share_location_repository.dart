import 'package:smgo/core/resources/data_state.dart';

abstract class ShareLocationRepository {
  Future<DataState<String>> getShareLocationUrl({
    required String deliveryRouteId,
    required String deliveryOrderId,
  });
}
