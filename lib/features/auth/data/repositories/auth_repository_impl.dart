import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<User> login({required String email, required String password}) async {
    final result = await _remoteDataSource.login(email: email, password: password);
    await _storageService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result.user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final result = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    await _storageService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    return result.user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasToken = await _storageService.hasToken();
    if (!hasToken) return null;

    try {
      final user = await _remoteDataSource.getMe();
      return user;
    } on ApiException catch (_) {
      await _storageService.clearAll();
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
    } finally {
      await _storageService.clearAll();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _storageService.hasToken();
  }
}
