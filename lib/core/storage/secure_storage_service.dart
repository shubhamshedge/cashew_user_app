import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
