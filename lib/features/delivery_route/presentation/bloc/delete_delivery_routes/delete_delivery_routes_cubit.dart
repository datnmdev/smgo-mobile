import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/delete_delivery_route_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_state.dart';

class DeleteDeliveryRoutesCubit extends Cubit<DeleteDeliveryRoutesState> {
  final DeleteDeliveryRouteUsecase deleteDeliveryRouteUsecase;

  DeleteDeliveryRoutesCubit({required this.deleteDeliveryRouteUsecase})
    : super(const DeleteDeliveryRoutesInitial());

  Future<void> call(List<String> routeIds) async {
    emit(const DeleteDeliveryRoutesLoading());
    await Future.wait(
      routeIds.map(
        (routeId) => deleteDeliveryRouteUsecase.call(
          params: DeleteDeliveryRouteUsecaseParams(id: routeId),
        ),
      ),
    );
    emit(const DeleteDeliveryRoutesDone());
  }
}
