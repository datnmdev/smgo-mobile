import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/location/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';

class AddLocationUsecase
    implements Usecase<DataState<LocationEntity>, AddLocationParams> {
  final LocationRepository locationRepository;

  AddLocationUsecase({required this.locationRepository});

  @override
  Future<DataState<LocationEntity>> call({required AddLocationParams params}) {
    return locationRepository.saveLocation(
      data: SaveLocationData(
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

class AddLocationParams {
  final String locationName;
  final String contactName;
  final String contactPhone;
  final List<String>? mediaIds;
  final String? note;
  final String address;
  final LocationData location;

  AddLocationParams({
    required this.locationName,
    required this.contactName,
    required this.contactPhone,
    this.mediaIds,
    required this.address,
    required this.location,
    this.note,
  });
}
