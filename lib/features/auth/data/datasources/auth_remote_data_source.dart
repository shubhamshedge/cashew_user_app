import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<UserModel> getMe();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _dioClient.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dioClient.get('/auth/me');
    return UserModel.fromJson(response['user'] ?? response);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post('/auth/logout');
  }
}
