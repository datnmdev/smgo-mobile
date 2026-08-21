import 'package:shipgo/core/network/api_response.dart';
import 'package:shipgo/shared/domain/entities/location_entity.dart';

abstract class GetMyLocationsState {
  final Pagination<LocationEntity>? data;
  const GetMyLocationsState({this.data});
}

class GetMyLocationsInitial extends GetMyLocationsState {
  const GetMyLocationsInitial({required super.data});
}

class GetMyLocationsLoading extends GetMyLocationsState {
  const GetMyLocationsLoading({required super.data});
}

class GetMyLocationsDone extends GetMyLocationsState {
  const GetMyLocationsDone({required super.data});
}

class GetMyLocationsFailed extends GetMyLocationsState {
  final Object error;

  const GetMyLocationsFailed({required this.error, required super.data});
}
