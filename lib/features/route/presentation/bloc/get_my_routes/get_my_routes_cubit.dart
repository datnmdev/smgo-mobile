import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/route/domain/usecases/get_my_routes_usecase.dart';
import 'package:shipgo/features/route/presentation/bloc/get_my_routes/get_my_routes_state.dart';

class GetMyRoutesCubit extends Cubit<GetMyRoutesState> {
  final GetMyRoutesUsecase getMyRoutesUsecase;

  GetMyRoutesCubit({required this.getMyRoutesUsecase})
    : super(const GetMyRoutesInitial());

  Future<void> call({required GetMyRoutesUsecaseParams params}) async {
    emit(
      GetMyRoutesLoading(isFirstLoad: state.isFirstLoad, routes: state.routes),
    );
    final dataState = await getMyRoutesUsecase.call(params: params);
    if (dataState is DataSuccess) {
      emit(
        GetMyRoutesDone(
          routes: dataState.data!.data,
          isFirstLoad: state.isFirstLoad && false,
        ),
      );
    } else if (dataState is DataFailed) {
      emit(
        GetMyRoutesFailed(
          routes: state.routes,
          error: dataState.error!,
          isFirstLoad: state.isFirstLoad && false,
        ),
      );
    }
  }
}
