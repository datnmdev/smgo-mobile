import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/shared/presentation/bloc/selection/selection_state.dart';

class SelectionCubit<T> extends Cubit<SelectionState<T>> {
  SelectionCubit() : super(SelectionState<T>());

  void toggleSelection({required T item}) {
    if (state.selectedItems.contains(item)) {
      var selectedItems = state.selectedItems..remove(item);
      emit(state.copyWith(selectedItems: selectedItems) as SelectionState<T>);
      if (selectedItems.isEmpty) {
        emit(state.copyWith(isEnabled: false) as SelectionState<T>);
      }
    } else {
      emit(
        state.copyWith(
              selectedItems: state.selectedItems..add(item),
              isEnabled: true,
            )
            as SelectionState<T>,
      );
    }
  }

  void toggleSelectAll({required List<T> currentItems}) {
    final isAllSelected = currentItems.every(state.selectedItems.contains);
    if (isAllSelected) {
      emit(
        state.copyWith(
              selectedItems: state.selectedItems..removeAll(currentItems),
              isEnabled: false,
            )
            as SelectionState<T>,
      );
    } else {
      emit(
        state.copyWith(
              selectedItems: state.selectedItems..addAll(currentItems),
              isEnabled: true,
            )
            as SelectionState<T>,
      );
    }
  }

  void closeSelectionMode() {
    emit(
      state.copyWith(isEnabled: false, selectedItems: {}) as SelectionState<T>,
    );
  }
}
