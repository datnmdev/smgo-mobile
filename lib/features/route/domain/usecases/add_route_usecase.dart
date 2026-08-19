import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/core/resources/usecase.dart';
import 'package:shipgo/features/route/domain/repository/route_repository.dart';

class AddRouteUsecase implements Usecase<dynamic, AddRouteUsecaseParams> {
  final RouteRepository routeRepository;

  const AddRouteUsecase({required this.routeRepository});

  @override
  Future<DataState<dynamic>> call({required AddRouteUsecaseParams params}) {
    return routeRepository.addRoute(params: AddRouteParams(name: params.name));
  }
}

class AddRouteUsecaseParams {
  final String name;

  const AddRouteUsecaseParams({required this.name});
}
