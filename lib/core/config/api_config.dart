import 'env_config.dart';

class ApiConfig {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Duration get connectionTimeout => Duration(seconds: EnvConfig.apiTimeoutSeconds);
  static Duration get receiveTimeout => Duration(seconds: EnvConfig.apiTimeoutSeconds);
}
