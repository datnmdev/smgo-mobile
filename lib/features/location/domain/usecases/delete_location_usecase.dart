import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';

class DeleteLocationUsecase implements Usecase<dynamic, DeleteLocationParams> {
  final LocationRepository locationRepository;

  DeleteLocationUsecase({ required this.locationRepository });

  @override
  Future<dynamic> call({required DeleteLocationParams params}) {
    return locationRepository.deleteLocation(locationId: params.locationId);
  }
}

class DeleteLocationParams {
  final String locationId;

  const DeleteLocationParams({required this.locationId});
}
