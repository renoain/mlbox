import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/storage.dart';
import '../models/user.dart';

class AuthState {
  final bool isLoading;
  final bool isCheckingSession;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isCheckingSession = true,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isCheckingSession,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isCheckingSession: isCheckingSession ?? this.isCheckingSession,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(const AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        state = state.copyWith(isCheckingSession: false, clearUser: true);
        return;
      }

      final response = await _api.dio.get('/me');
      final body = response.data;

      final data = body is Map && body['data'] is Map
          ? body['data'] as Map
          : body as Map;

      state = state.copyWith(
        user: User.fromJson(Map<String, dynamic>.from(data)),
        isCheckingSession: false,
        clearError: true,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await TokenStorage.deleteToken();
      }

      state = state.copyWith(isCheckingSession: false, clearUser: true);
    } catch (_) {
      // Jika server tidak bisa dijangkau, jangan menganggap
      // sesi valid. Token dipertahankan agar bisa dicoba lagi.
      state = state.copyWith(isCheckingSession: false, clearUser: true);
    }
  }

  Future<void> checkAuthStatus() async {
    if (state.isCheckingSession) {
      // Tunggu pemeriksaan sesi yang sudah berjalan.
      while (state.isCheckingSession) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    await checkSession();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? body['data'] as Map
          : body as Map;

      final token = data['token'];
      final userJson = data['user'];

      if (token == null || userJson is! Map) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Respons login tidak valid.',
        );
        return false;
      }

      await TokenStorage.saveToken(token.toString());

      state = state.copyWith(
        isLoading: false,
        isCheckingSession: false,
        user: User.fromJson(Map<String, dynamic>.from(userJson)),
        clearError: true,
      );

      return true;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = responseData is Map
          ? responseData['message']?.toString()
          : null;

      state = state.copyWith(
        isLoading: false,
        errorMessage: message ?? 'Login gagal. Periksa koneksi.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat login.',
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _api.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? body['data'] as Map
          : body as Map;

      final token = data['token'];
      final userJson = data['user'];

      if (token == null || userJson is! Map) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Respons registrasi tidak valid.',
        );
        return false;
      }

      await TokenStorage.saveToken(token.toString());

      state = state.copyWith(
        isLoading: false,
        isCheckingSession: false,
        user: User.fromJson(Map<String, dynamic>.from(userJson)),
        clearError: true,
      );

      return true;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = responseData is Map
          ? responseData['message']?.toString()
          : null;

      state = state.copyWith(
        isLoading: false,
        errorMessage: message ?? 'Registrasi gagal.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat registrasi.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/logout');
    } catch (_) {
      // Logout lokal tetap dilakukan jika server tidak tersedia.
    } finally {
      await TokenStorage.deleteToken();
      state = const AuthState(isLoading: false, isCheckingSession: false);
    }
  }
}
