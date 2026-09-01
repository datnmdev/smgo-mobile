import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/location/domain/repository/location_repository.dart';

class UpdateLocationUsecase
    implements Usecase<DataState<dynamic>, UpdateLocationUsecaseParams> {
  final LocationRepository locationRepository;

  UpdateLocationUsecase({required this.locationRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateLocationUsecaseParams params,
  }) {
    return locationRepository.updateLocation(
      locationId: params.locationId,
      data: UpdateLocationData(
        locationName: params.locationName,
        contactName: params.contactName,
        contactPhone: params.contactPhone,
        address: params.address,
        mediaIds: params.mediaIds,
        location: params.location,
        note: params.note,
      ),
    );
  }
}

class UpdateLocationUsecaseParams {
  final String locationId;
  final String locationName;
  final String contactName;
  final String contactPhone;
  final List<String>? mediaIds;
  final String? note;
  final String address;
  final LocationData location;

  UpdateLocationUsecaseParams({
    required this.locationId,
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    this.mediaIds,
    required this.address,
    required this.location,
    this.note,
  });
}
