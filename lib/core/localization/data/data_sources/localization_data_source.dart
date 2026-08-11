import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalizationDataSource {
  factory LocalizationDataSource() = _LocalizationDataSource;

  Future<String?> get(String key);
  Future<void> write(String key, String value);
}

class _LocalizationDataSource implements LocalizationDataSource {
  const _LocalizationDataSource();

  @override
  Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
