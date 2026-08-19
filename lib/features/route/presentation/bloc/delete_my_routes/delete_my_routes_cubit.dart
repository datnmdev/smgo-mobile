import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/route/domain/usecases/delete_my_route_usecase.dart';
import 'package:shipgo/features/route/presentation/bloc/delete_my_routes/delete_my_routes_state.dart';

class DeleteMyRoutesCubit extends Cubit<DeleteMyRoutesState> {
  final DeleteMyRouteUsecase deleteMyRouteUsecase;

  DeleteMyRoutesCubit({required this.deleteMyRouteUsecase})
    : super(const DeleteMyRoutesInitial());

  Future<void> call(List<String> routeIds) async {
    emit(const DeleteMyRoutesLoading());
    await Future.wait(
      routeIds.map(
        (routeId) => deleteMyRouteUsecase.call(
          params: DeleteMyRouteUsecaseParams(id: routeId),
        ),
      ),
    );
    emit(const DeleteMyRoutesDone());
  }
}
