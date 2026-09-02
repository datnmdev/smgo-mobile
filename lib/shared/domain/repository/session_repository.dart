import 'package:smgo/core/resources/data_state.dart';

abstract class SessionRepository {
  Future<DataState<dynamic>> signout();
}
