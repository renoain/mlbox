import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/storage.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(AuthState()) {
    checkAuthStatus(); // Cek token saat aplikasi pertama dibuka
  }

  // Cek apakah user punya token di HP (sudah login sebelumnya)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final token = await TokenStorage.getToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  // Fungsi Login (dipanggil dari halaman Login)
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Sesuaikan path JSON ini dengan respons backend lama (Mailboxh)
      final token = response.data['data']?['token'] ?? response.data['token'];

      if (token != null) {
        await TokenStorage.saveToken(token);
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return true;
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login gagal';
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  // Fungsi Logout (dipanggil dari Profil)
  Future<void> logout() async {
    await TokenStorage.deleteToken();
    state = AuthState(isAuthenticated: false);
  }
}
