class SelectionState<T> {
  final bool isEnabled;
  final Set<T> selectedItems;

  SelectionState({this.isEnabled = false, this.selectedItems = const {}});

  SelectionState<T> copyWith({bool? isEnabled, Set<T>? selectedItems}) {
    return SelectionState(
      isEnabled: isEnabled ?? this.isEnabled,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }
}
