import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_store/core/config/env_config.dart';
import 'package:cashew_store/core/config/api_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnvConfig tests', () {
    test('EnvConfig defaults and getters work gracefully when uninitialized', () {
      expect(EnvConfig.appEnv, isNotEmpty);
      expect(EnvConfig.appName, isNotEmpty);
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
      expect(EnvConfig.apiTimeoutSeconds, greaterThan(0));
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.connectionTimeout.inSeconds, greaterThan(0));
    });
  });
}
