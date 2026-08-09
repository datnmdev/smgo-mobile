import 'package:json_annotation/json_annotation.dart';

part 'sign_in_with_google_request.g.dart';

@JsonSerializable()
class SignInWithGoogleBodyRequest {
  final String idToken;
  const SignInWithGoogleBodyRequest({required this.idToken});
  Map<String, dynamic> toJson() => _$SignInWithGoogleBodyRequestToJson(this);
}
