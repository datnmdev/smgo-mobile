import 'package:json_annotation/json_annotation.dart';

part 'sign_in_with_facebook_request.g.dart';

@JsonSerializable()
class SignInWithFacebookBodyRequest {
  final String inputToken;
  const SignInWithFacebookBodyRequest({required this.inputToken});
  Map<String, dynamic> toJson() => _$SignInWithFacebookBodyRequestToJson(this);
}
