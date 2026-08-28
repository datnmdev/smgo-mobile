import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shipgo/core/network/api_enpoints.dart';
import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/features/delivery_route/data/models/delivery_route_model.dart';

part 'delivery_route_api_service.g.dart';

@RestApi()
abstract class DeliveryRouteApiService {
  factory DeliveryRouteApiService(Dio dio) = _DeliveryRouteApiService;

  @GET(ApiEndpoints.getDeliveryRoutes)
  Future<HttpResponse<ApiResponse<Pagination<DeliveryRouteModel>>>>
  getDeliveryRoutes({
    @Queries() required GetDeliveryRoutesQueryRequest queries,
  });

  @POST(ApiEndpoints.addDeliveryRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> addDeliveryRoute({
    @Body() required AddDeliveryRouteBodyRequest body,
  });

  @PUT(ApiEndpoints.updateDeliveryRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> updateDeliveryRoute({
    @Path('deliveryRouteId') required String id,
    @Body() required UpdateDeliveryRouteBodyRequest body,
  });

  @DELETE(ApiEndpoints.deleteDeliveryRoute)
  Future<HttpResponse<ApiResponse<dynamic>>> deleteDeliveryRoute({
    @Path('deliveryRouteId') required String id,
  });

  // Delivery order
  @POST(ApiEndpoints.addDeliveryOrder)
  Future<HttpResponse<ApiResponse<dynamic>>> addDeliveryOrder({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required AddDeliveryOrderBodyRequest body,
  });

  @PUT(ApiEndpoints.updateDeliveryOrder)
  Future<HttpResponse<ApiResponse<dynamic>>> updateDeliveryOrder({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Path('deliveryOrderId') required String deliveryOrderId,
    @Body() required UpdateDeliveryOrderBodyRequest body,
  });

  @PUT(ApiEndpoints.recheckDeliveryOrders)
  Future<HttpResponse<ApiResponse<dynamic>>> recheckDeliveryOrders({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required RecheckDeliveryOrdersBodyRequest body,
  });

  @PUT(ApiEndpoints.confirmDeliveryOrders)
  Future<HttpResponse<ApiResponse<dynamic>>> confirmDeliveryOrders({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required ConfirmDeliveryOrdersBodyRequest body,
  });

  @PUT(ApiEndpoints.sortDeliveryOrders)
  Future<HttpResponse<ApiResponse<dynamic>>> sortDeliveryOrders({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required SortDeliveryOrdersBodyRequest body,
  });

  @DELETE(ApiEndpoints.deleteDeliveryOrders)
  Future<HttpResponse<ApiResponse<dynamic>>> deleteDeliveryOrders({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required DeleteDeliveryOrdersBodyRequest body,
  });

  @PUT(ApiEndpoints.confirmSortedDeliveryOrders)
  Future<HttpResponse<ApiResponse<dynamic>>> confirmSortedDeliveryOrders({
    @Path('deliveryRouteId') required String deliveryRouteId,
    @Body() required ConfirmSortedDeliveryOrdersBodyRequest body,
  });
}

@JsonSerializable(includeIfNull: false)
class GetDeliveryRoutesQueryRequest {
  final String? keyword;
  final int? pageNumber;
  final int? pageSize;
  final String? id;
  final String? status;

  GetDeliveryRoutesQueryRequest({
    this.keyword,
    this.pageNumber,
    this.pageSize,
    this.id,
    this.status,
  });

  Map<String, dynamic> toJson() => _$GetDeliveryRoutesQueryRequestToJson(this);
}

@JsonSerializable()
class AddDeliveryRouteBodyRequest {
  final String name;

  AddDeliveryRouteBodyRequest({required this.name});

  Map<String, dynamic> toJson() => _$AddDeliveryRouteBodyRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateDeliveryRouteBodyRequest {
  final String? name;
  final String? status;

  UpdateDeliveryRouteBodyRequest({this.name, this.status});

  Map<String, dynamic> toJson() => _$UpdateDeliveryRouteBodyRequestToJson(this);
}

// Delivery order
@JsonSerializable()
class PointRequestData {
  final double x;
  final double y;

  PointRequestData({required this.x, required this.y});

  Map<String, dynamic> toJson() => _$PointRequestDataToJson(this);
  factory PointRequestData.fromJson(Map<String, dynamic> obj) =>
      _$PointRequestDataFromJson(obj);
}

@JsonSerializable(includeIfNull: false)
class AddDeliveryOrderBodyRequest {
  final String orderCode;
  final String? orderName;
  final String? orderMediaId;
  final String contactName;
  final String contactPhone;
  final String address;
  final String? appliedLocationId;
  final PointRequestData location;

  AddDeliveryOrderBodyRequest({
    required this.orderCode,
    required this.orderName,
    this.orderMediaId,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    this.appliedLocationId,
    required this.location,
  });

  Map<String, dynamic> toJson() => _$AddDeliveryOrderBodyRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateDeliveryOrderBodyRequest {
  final String? orderCode;
  final String? orderName;
  @JsonKey(includeIfNull: true)
  final String? orderMediaId;
  final String? status;
  final String? contactName;
  final String? contactPhone;
  final String? address;
  final PointRequestData? location;
  @JsonKey(includeIfNull: true)
  final String? appliedLocationId;

  UpdateDeliveryOrderBodyRequest({
    this.orderCode,
    this.orderName,
    this.orderMediaId,
    this.status,
    this.contactName,
    this.contactPhone,
    this.address,
    this.location,
    this.appliedLocationId,
  });

  Map<String, dynamic> toJson() => _$UpdateDeliveryOrderBodyRequestToJson(this);
}

@JsonSerializable()
class RecheckDeliveryOrdersBodyRequest {
  final List<String> deliveryOrderIds;

  RecheckDeliveryOrdersBodyRequest({required this.deliveryOrderIds});

  Map<String, dynamic> toJson() =>
      _$RecheckDeliveryOrdersBodyRequestToJson(this);
}

@JsonSerializable()
class ConfirmDeliveryOrdersBodyRequest {
  final List<String> deliveryOrderIds;

  ConfirmDeliveryOrdersBodyRequest({required this.deliveryOrderIds});

  Map<String, dynamic> toJson() =>
      _$ConfirmDeliveryOrdersBodyRequestToJson(this);
}

@JsonSerializable()
class DeleteDeliveryOrdersBodyRequest {
  final List<String> deliveryOrderIds;

  DeleteDeliveryOrdersBodyRequest({required this.deliveryOrderIds});

  Map<String, dynamic> toJson() =>
      _$DeleteDeliveryOrdersBodyRequestToJson(this);
}

@JsonSerializable()
class SortDeliveryOrdersBodyRequest {
  final PointRequestData source;

  SortDeliveryOrdersBodyRequest({required this.source});

  Map<String, dynamic> toJson() => _$SortDeliveryOrdersBodyRequestToJson(this);
}

@JsonSerializable()
class ConfirmSortedDeliveryOrdersBodyRequest {
  final List<String> deliveryOrderIds;

  ConfirmSortedDeliveryOrdersBodyRequest({required this.deliveryOrderIds});

  Map<String, dynamic> toJson() =>
      _$ConfirmSortedDeliveryOrdersBodyRequestToJson(this);
}
