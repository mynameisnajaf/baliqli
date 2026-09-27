import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';

class AuthState {
  final bool loading;
  final bool authenticated;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.loading = false,
    this.authenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    bool? authenticated,
    Map<String, dynamic>? user,
    String? error,
  }) =>
      AuthState(
        loading: loading ?? this.loading,
        authenticated: authenticated ?? this.authenticated,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(const AuthState()) {
    _bootstrap();
  }

  final ApiClient _api;

  Future<void> _bootstrap() async {
    final token = await _api.getToken();
    if (token == null) return;
    try {
      final res = await _api.dio.get('/api/auth/me');
      state = AuthState(authenticated: true, user: res.data as Map<String, dynamic>);
    } catch (_) {
      await _api.clearToken();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _api.dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _api.saveToken(res.data['access_token'] as String);
      final me = await _api.dio.get('/api/auth/me');
      state = AuthState(authenticated: true, user: me.data as Map<String, dynamic>);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Giriş uğursuz oldu',
      );
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _api.dio.post('/api/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
      });
      await _api.saveToken(res.data['access_token'] as String);
      final me = await _api.dio.get('/api/auth/me');
      state = AuthState(authenticated: true, user: me.data as Map<String, dynamic>);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Qeydiyyat uğursuz oldu',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});
