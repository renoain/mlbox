import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import '../providers/auth_provider.dart'; // (Nanti kita sambungkan)

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Android emulator tidak bisa mengakses `127.0.0.1` host lewat alamat itu;
  /// harus memakai `10.0.2.2`. Web/desktop tetap memakai `127.0.0.1`.
  static String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  ApiClient() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Accept'] = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Jika error 401 (Unauthorized / Token Expired)
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token'); // Hapus token lokal
            // Di sini nanti kita bisa menambahkan kode untuk redirect ke /login
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
