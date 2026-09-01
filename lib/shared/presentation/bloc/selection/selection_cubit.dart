import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_state.dart';

class SelectionCubit<T> extends Cubit<SelectionState<T>> {
  SelectionCubit() : super(SelectionState<T>());

  void toggleSelection({required T item}) {
    // 1. Tạo một Set mới bằng cú pháp spread (...) để không làm thay đổi state cũ
    final updatedItems = Set<T>.from(state.selectedItems);

    if (updatedItems.contains(item)) {
      updatedItems.remove(item);
      emit(
        state.copyWith(
          selectedItems: updatedItems,
          isEnabled: updatedItems.isNotEmpty, // Nếu hết item thì tự tắt isEnabled luôn cho gọn
        ),
      );
    } else {
      updatedItems.add(item);
      emit(
        state.copyWith(
          selectedItems: updatedItems,
          isEnabled: true,
        ),
      );
    }
  }

  void toggleSelectAll({required List<T> currentItems}) {
    final updatedItems = Set<T>.from(state.selectedItems);
    final isAllSelected = currentItems.every(updatedItems.contains);

    if (isAllSelected) {
      updatedItems.removeAll(currentItems);
      emit(
        state.copyWith(
          selectedItems: updatedItems,
          isEnabled: updatedItems.isNotEmpty,
        ),
      );
    } else {
      updatedItems.addAll(currentItems);
      emit(
        state.copyWith(
          selectedItems: updatedItems,
          isEnabled: true,
        ),
      );
    }
  }

  void closeSelectionMode() {
    emit(
      state.copyWith(
        isEnabled: false, 
        selectedItems: <T>{}, // Truyền đúng kiểu Set<T> rỗng
      ),
    );
  }
}