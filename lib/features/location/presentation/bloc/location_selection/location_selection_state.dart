class LocationSelectionState {
  final bool isActivated;
  final Set<String> selectedLocationIdsSet;
  final bool isDeletingSelectedLocations;

  LocationSelectionState({
    this.isActivated = false,
    required this.selectedLocationIdsSet,
    this.isDeletingSelectedLocations = false,
  });

  LocationSelectionState copyWith({
    bool? isActivated,
    bool? isDeletingSelectedLocations,
    Set<String>? selectedLocationIdsSet,
    Set<String>? deleteLocationIdsSet,
  }) {
    return LocationSelectionState(
      isActivated: isActivated ?? this.isActivated,
      selectedLocationIdsSet:
          selectedLocationIdsSet ?? this.selectedLocationIdsSet,
      isDeletingSelectedLocations:
          isDeletingSelectedLocations ?? this.isDeletingSelectedLocations,
    );
  }
}
