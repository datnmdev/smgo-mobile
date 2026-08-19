import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/route/domain/repository/route_repository.dart';

class UpdateMyRouteUsecase
    implements Usecase<dynamic, UpdateMyRouteUsecaseParams> {
  final RouteRepository routeRepository;

  const UpdateMyRouteUsecase({required this.routeRepository});

  @override
  Future<DataState<dynamic>> call({
    required UpdateMyRouteUsecaseParams params,
  }) {
    return routeRepository.updateMyRoute(
      id: params.id,
      params: UpdateMyRouteParams(name: params.name),
    );
  }
}

class UpdateMyRouteUsecaseParams {
  final String id;
  final String? name;

  const UpdateMyRouteUsecaseParams({required this.id, this.name});
}
