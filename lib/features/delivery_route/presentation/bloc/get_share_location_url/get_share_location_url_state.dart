class GetShareLocationUrlState {
  const GetShareLocationUrlState();
}

class GetShareLocationUrlInitial extends GetShareLocationUrlState {
  const GetShareLocationUrlInitial();
}

class GetShareLocationUrlLoading extends GetShareLocationUrlState {
  const GetShareLocationUrlLoading();
}

class GetShareLocationUrlDone extends GetShareLocationUrlState {
  final String shareLocationUrl;
  const GetShareLocationUrlDone({required this.shareLocationUrl});
}

class GetShareLocationUrlFailed extends GetShareLocationUrlState {
  final Object error;

  GetShareLocationUrlFailed({required this.error});
}
