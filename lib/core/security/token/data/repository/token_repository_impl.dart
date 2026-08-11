import 'package:shipgo/core/security/token/data/data_sources/token_data_source.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';

class TokenRepositoryImpl implements TokenRepository {
  final String _accessTokenKey = "access_token";
  final String _refreshTokenKey = "refresh_token";
  String? _accessToken;
  String? _refreshToken;
  final TokenDataSource _tokenDataSource;

  TokenRepositoryImpl(TokenDataSource tokenDataSource)
    : _tokenDataSource = tokenDataSource;

  @override
  Future<String?> getAccessToken() async {
    return _accessToken ?? _tokenDataSource.get(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _refreshToken ?? _tokenDataSource.get(key: _refreshTokenKey);
  }

  @override
  Future<void> saveAccessToken(String value) async {
    _accessToken = value;
    await _tokenDataSource.write(key: _accessTokenKey, value: value);
  }

  @override
  Future<void> saveRefreshToken(String value) async {
    _refreshToken = value;
    await _tokenDataSource.write(key: _refreshTokenKey, value: value);
  }

  @override
  Future<void> clearToken() async {
    _accessToken = null;
    _refreshToken = null;
    await _tokenDataSource.delete(key: _accessTokenKey);
    await _tokenDataSource.delete(key: _refreshTokenKey);
  }
}
