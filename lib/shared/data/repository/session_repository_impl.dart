import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/shared/data/data_sources/session_api_service.dart';
import 'package:smgo/shared/domain/repository/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionApiService sessionApiService;

  SessionRepositoryImpl({required this.sessionApiService});

  @override
  Future<DataState<dynamic>> signout() async {
    try {
      final httpResponse = await sessionApiService.signout();
      return DataSuccess(httpResponse.data.data);
    } catch (e) {
      return DataFailed(e);
    }
  }
}
