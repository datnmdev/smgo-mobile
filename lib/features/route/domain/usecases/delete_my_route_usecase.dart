import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/route/domain/repository/route_repository.dart';

class DeleteMyRouteUsecase
    implements Usecase<DataState<dynamic>, DeleteMyRouteUsecaseParams> {
  final RouteRepository routeRepository;

  const DeleteMyRouteUsecase({required this.routeRepository});

  @override
  Future<DataState<dynamic>> call({
    required DeleteMyRouteUsecaseParams params,
  }) {
    return routeRepository.deleteMyRoute(
      params: DeleteMyRouteParams(id: params.id),
    );
  }
}

class DeleteMyRouteUsecaseParams {
  final String id;

  const DeleteMyRouteUsecaseParams({required this.id});
}
