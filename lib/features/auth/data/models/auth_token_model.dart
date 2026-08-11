import 'package:json_annotation/json_annotation.dart';
import 'package:shipgo/features/auth/domain/entities/auth_token_entity.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
class AuthTokensModel extends AuthTokensEntity {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);
}
