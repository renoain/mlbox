import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_config.dart';

// import '../providers/auth_provider.dart'; // (Nanti kita sambungkan)

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl = ApiConfig.apiBaseUrl;
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
