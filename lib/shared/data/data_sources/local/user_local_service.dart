import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shipgo/core/security/token/domain/repository/token_repository.dart';
import 'package:shipgo/shared/data/models/user_model.dart';

class UserLocalService {
  final TokenRepository tokenRepository;

  UserLocalService({required this.tokenRepository});

  Future<UserModel?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userModelJsonString = prefs.getString('profile');
    if (userModelJsonString != null) {
      Map<String, dynamic> json = jsonDecode(userModelJsonString);
      return UserModel(
        id: json['id'],
        name: json['name'],
        provider: json['provider'],
        uuid: json['uuid'],
        createdAt: DateTime.parse(json['createdAt']),
      );
    }
    return null;
  }

  Future<void> saveProfile({required UserModel userModel}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(userModel.toJson()));
  }
}
