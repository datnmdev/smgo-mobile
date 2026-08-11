import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenDataSource {
  factory TokenDataSource() = _TokenDataSource;

  Future<String?> get({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}

class _TokenDataSource implements TokenDataSource {
  final FlutterSecureStorage _flutterSecureStorage;

  _TokenDataSource() : _flutterSecureStorage = FlutterSecureStorage();

  @override
  Future<String?> get({required String key}) {
    return _flutterSecureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _flutterSecureStorage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _flutterSecureStorage.delete(key: key);
  }
}
