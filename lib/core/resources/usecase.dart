abstract interface class Usecase<ReturnType, Params> {
  Future<ReturnType> call({Params params});
}
