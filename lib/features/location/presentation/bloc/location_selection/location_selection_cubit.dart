import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/features/location/presentation/bloc/location_selection/location_selection_state.dart';

class LocationSelectionCubit extends Cubit<LocationSelectionState> {
  LocationSelectionCubit()
    : super(LocationSelectionState(selectedLocationIdsSet: {}));

  void startDeleteSelectedLocations() {
    emit(state.copyWith(isDeletingSelectedLocations: true));
  }

  void endDeleteSelectedLocations() {
    emit(state.copyWith(isDeletingSelectedLocations: false));
  }

  void selectLocation(String locationId) {
    emit(
      state.copyWith(
        selectedLocationIdsSet: Set.from(state.selectedLocationIdsSet)
          ..add(locationId),
      ),
    );
  }

  void deselectLocation(String locationId) {
    emit(
      state.copyWith(
        selectedLocationIdsSet: Set.from(state.selectedLocationIdsSet)
          ..remove(locationId),
      ),
    );
  }

  void clearSelection() {
    emit(state.copyWith(selectedLocationIdsSet: const {}));
  }

  void enableSelectionMode() {
    emit(state.copyWith(isActivated: true));
  }

  void disableSelectionMode() {
    emit(state.copyWith(isActivated: false));
  }
}
