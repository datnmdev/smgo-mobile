import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/resources/usecase.dart';
import 'package:smgo/features/location/domain/repository/location_repository.dart';

class DeleteLocationsUsecase
    implements Usecase<DataState<dynamic>, DeleteLocationsParams> {
  final LocationRepository locationRepository;

  DeleteLocationsUsecase({required this.locationRepository});

  @override
  Future<DataState<dynamic>> call({required DeleteLocationsParams params}) {
    return locationRepository.deleteLocations(locationIds: params.locationIds);
  }
}

class DeleteLocationsParams {
  final List<String> locationIds;

  const DeleteLocationsParams({required this.locationIds});
}
