import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        CrashlyticsService.setUserIdentifier('${user.id} (${user.email})');
        CrashlyticsService.setCustomKey('user_role', user.role);
        CrashlyticsService.log('User session verified: ${user.email}');
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email: email, password: password);
      CrashlyticsService.setUserIdentifier('${user.id} (${user.email})');
      CrashlyticsService.setCustomKey('user_role', user.role);
      CrashlyticsService.log('User logged in: ${user.email}');
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack, reason: 'Login exception');
      emit(const AuthError('An unexpected error occurred during login.'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      CrashlyticsService.setUserIdentifier('${user.id} (${user.email})');
      CrashlyticsService.setCustomKey('user_role', user.role);
      CrashlyticsService.log('User registered: ${user.email}');
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack, reason: 'Registration exception');
      emit(const AuthError('An unexpected error occurred during registration.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await CrashlyticsService.clearUserIdentifier();
    CrashlyticsService.log('User logged out');
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}
