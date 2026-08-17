import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _Env.apiBaseUrl;
  @EnviedField(varName: 'GOOGLE_SERVER_CLIENT_ID', obfuscate: true)
  static final String googleServerClientId = _Env.googleServerClientId;
  @EnviedField(varName: 'MAP_TEMPLATE_URL', obfuscate: true)
  static final String mapTemplateUrl = _Env.mapTemplateUrl;
  @EnviedField(varName: 'PACKAGE_NAME', obfuscate: true)
  static final String packageName = _Env.packageName;
}
