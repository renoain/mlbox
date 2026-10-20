class User {
  final int id;
  final String name;
  final String email;
  final String role;

  /// Tanggal akun dibuat, dipakai untuk menampilkan tanggal bergabung.
  final DateTime? createdAt;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
