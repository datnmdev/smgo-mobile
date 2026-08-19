abstract class GetUrlsState {
  const GetUrlsState();
}

class GetUrlsInitial extends GetUrlsState {
  const GetUrlsInitial();
}

class GetUrlsLoading extends GetUrlsState {
  const GetUrlsLoading();
}

class GetUrlsDone extends GetUrlsState {
  final List<String> urls;
  const GetUrlsDone({required this.urls});
}

class GetUrlsFailed extends GetUrlsState {
  final List<Object> errors;
  const GetUrlsFailed({required this.errors});
}
