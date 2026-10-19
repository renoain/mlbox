// Fungsi untuk mengecek apakah user sudah login sebelumnya (dipanggil di Splash/Home)
Future<void> checkSession() async {
  final token = await TokenStorage.getToken();
  if (token != null) {
    // Jika token ada, kita anggap valid. (Bisa ditingkatkan dengan memanggil /user endpoint)
    state = state.copyWith(isAuthenticated: true);
    // Catatan: Idealnya ambil data user dari /api/user lalu simpan ke state
  }
}

// Fungsi Register
Future<bool> register(String name, String email, String password) async {
  state = state.copyWith(isLoading: true, errorMessage: null);
  try {
    final response = await _api.dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password, // Jika backend minta konfirmasi
      },
    );

    final data = response.data['data'] ?? response.data;
    final token = data['token'];
    final userJson = data['user'];

    if (token != null) {
      await TokenStorage.saveToken(token);
      final user = User.fromJson(userJson);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    }
    return false;
  } on DioException catch (e) {
    final message = e.response?.data['message'] ?? 'Register gagal.';
    state = state.copyWith(isLoading: false, errorMessage: message);
    return false;
  }
}
