abstract interface class Usecase<ReturnType, Params> {
  Future<ReturnType> call({required Params params});
}
