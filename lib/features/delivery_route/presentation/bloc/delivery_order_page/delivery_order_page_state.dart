enum DeliveryOrderPageTab {
  pending,
  checked,
  completedOverview,
  completedDelivered,
  completedCancelled,
  completedRescheduled,
}

const _absent = Object();

class DeliveryOrderPageState {
  final DeliveryOrderPageTab? selectedTab;

  const DeliveryOrderPageState({this.selectedTab});

  DeliveryOrderPageState copyWith({Object? selectedTab = _absent}) {
    return DeliveryOrderPageState(
      selectedTab: selectedTab == _absent
          ? this.selectedTab
          : selectedTab as DeliveryOrderPageTab?,
    );
  }
}
