import 'package:smgo/core/resources/data_state.dart';

abstract class TokenRepository {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveAccessToken(String value);
  Future<void> saveRefreshToken(String value);
  Future<DataState<dynamic>> clearToken();
}
